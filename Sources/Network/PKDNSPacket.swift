//
//  PKDNSPacket.swift
//  PKNetwork
//
//  Created by Plumk on 2022/6/1.
//

import Foundation

public struct PKDNSPacket: Sendable {
    
    enum ParseError: Error {
        case invaliedData
    }
    
    /// 标识
    public var ID: UInt16
    
    // flags
    public var QR: UInt8 // 1bit 0x8000 >> 15
    public var OPCODE: UInt8 // 4bit 0x7800 >> 11
    public var AA: UInt8 // 1bit 0x0400 >> 10
    public var TC: UInt8 // 1bit 0x0200 >> 9
    public var RD: UInt8 // 1bit 0x0100 >> 8
    public var RA: UInt8 // 1bit 0x0080 >> 7
    public var Z: UInt8 // 3bit 0x0070 >> 4
    public var RCODE: UInt8 // 4bit 0x000F >> 0
    
    /// 问题
    public var Questions: [Question]
    
    /// 回答
    public var Answers: [ResourceRecord]
    
    /// 权威回答
    public var Authoritys: [ResourceRecord]
    
    /// 附加回答
    public var Additionals: [ResourceRecord]
    
    /// 生成查询报文
    /// - Parameters:
    ///   - domain:
    ///   - type:
    public init(query domain: String, type: QueryType) {
        self.ID = UInt16.random(in: 0 ... 0xFFFF)
        self.QR = 0
        self.OPCODE = 0
        self.AA = 0
        self.TC = 0
        self.RD = 1
        self.RA = 1
        self.Z = 0
        self.RCODE = 0
        
        self.Questions = [.init(domain: domain, qtype: type, qclass: 1)]
        self.Answers = []
        self.Authoritys = []
        self.Additionals = []
    }
    
    public init(cloneRequest packet: PKDNSPacket) {
        self.ID = packet.ID
        self.QR = 0
        self.OPCODE = 0
        self.AA = 0
        self.TC = 0
        self.RD = 1
        self.RA = 1
        self.Z = 0
        self.RCODE = 0
        
        self.Questions = packet.Questions
        self.Answers = []
        self.Authoritys = []
        self.Additionals = []
    }
    
    /// 解析返回报文
    /// - Parameter data:
    public init(data: Data) throws {
        
        var offset = data.startIndex
        
        self.ID = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        let flags = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        self.QR = UInt8((flags & 0x8000) >> 15)
        self.OPCODE = UInt8((flags & 0x7800) >> 11)
        self.AA = UInt8((flags & 0x0400) >> 10)
        self.TC = UInt8((flags & 0x0200) >> 9)
        self.RD = UInt8((flags & 0x0100) >> 8)
        self.RA = UInt8((flags & 0x0080) >> 7)
        self.Z = UInt8((flags & 0x0070) >> 4)
        self.RCODE = UInt8((flags & 0x000F) >> 0)
        
        
        let QDCOUNT = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        let ANCOUNT = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        let NSCOUNT = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        let ARCOUNT = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2

        var questions = [Question]()
        for _ in 0 ..< QDCOUNT {
            
            let domain = try readDomainName(data: data, offset: &offset)
            
            let qtype = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            let qclass = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            questions.append(.init(domain: domain, qtype: .init(rawValue: qtype) ?? .none, qclass: qclass))
        }
        self.Questions = questions
        
        
        self.Answers = try parseRecords(data: data, count: Int(ANCOUNT), offset: &offset)
        self.Authoritys = try parseRecords(data: data, count: Int(NSCOUNT), offset: &offset)
        self.Additionals = try parseRecords(data: data, count: Int(ARCOUNT), offset: &offset)
    }
    
    
    /// 编码为data
    /// - Returns:
    public func encode() -> Data {
        
        
        /// 编码域名
        /// - Parameter domain:
        /// - Returns:
        func encodeDomain(_ domain: String, data: inout Data, domainOffset: inout [String: UInt16]) {
            
            let labels = domain.lowercased().split(separator: ".").map(String.init)
            
            for i in labels.startIndex ..< labels.endIndex {
                let label = labels[i]
                let subdomain = labels[i...].joined(separator: ".")
                
                if let offset = domainOffset[subdomain] {
                    data.append(contentsOf: (UInt16(0xC000) | UInt16(offset)).bytes)
                    return
                    
                } else {
                    domainOffset[subdomain] = UInt16(data.count)

                    data.append(UInt8(label.count))
                    data.append(label.data(using: .utf8)!)
                }
            }
            
            data.append(0x00)
        }
        
        
        /// 编码资源记录
        /// - Parameters:
        ///   - record:
        ///   - data:
        ///   - domainOffset:
        func encodeResourceRecord(_ record: ResourceRecord, data: inout Data, domainOffset: inout [String: UInt16]) {
            encodeDomain(record.domain, data: &data, domainOffset: &domainOffset)
            data.append(contentsOf: record.qtype.rawValue.bytes)
            data.append(contentsOf: record.qclass.bytes)
            data.append(contentsOf: record.ttl.bytes)
            data.append(contentsOf: record.rdlength.bytes)
            
            switch record.content {
            case let .NS(msdname):
                encodeDomain(msdname, data: &data, domainOffset: &domainOffset)
                
            case let .CNAME(cname):
                encodeDomain(cname, data: &data, domainOffset: &domainOffset)
            
            case let .SOA(soa):
                encodeDomain(soa.mname, data: &data, domainOffset: &domainOffset)
                encodeDomain(soa.rname, data: &data, domainOffset: &domainOffset)
                data.append(contentsOf: soa.serial.bytes)
                data.append(contentsOf: soa.refresh.bytes)
                data.append(contentsOf: soa.retry.bytes)
                data.append(contentsOf: soa.expire.bytes)
                data.append(contentsOf: soa.minimum.bytes)
                
            case let .PTR(ptrdname):
                encodeDomain(ptrdname, data: &data, domainOffset: &domainOffset)
                
            case let .HINFO(cpu, os):
                encodeDomain(cpu, data: &data, domainOffset: &domainOffset)
                encodeDomain(os, data: &data, domainOffset: &domainOffset)
                
            case let .MX(mx):
                data.append(contentsOf: mx.priority.bytes)
                encodeDomain(mx.host, data: &data, domainOffset: &domainOffset)
                
            case let .SRV(srv):
                data.append(contentsOf: srv.priority.bytes)
                data.append(contentsOf: srv.weight.bytes)
                data.append(contentsOf: srv.port.bytes)
                encodeDomain(srv.target, data: &data, domainOffset: &domainOffset)
                
            default:
                data.append(record.rdata)
            }
        }
        
        var data = Data()
        data.append(contentsOf: self.ID.bytes)
        
        var flags: UInt16 = 0
        flags |= UInt16(self.QR) << 15
        flags |= UInt16(self.OPCODE) << 11
        flags |= UInt16(self.AA) << 10
        flags |= UInt16(self.TC) << 9
        flags |= UInt16(self.RD) << 8
        flags |= UInt16(self.RA) << 7
        flags |= UInt16(self.Z) << 4
        flags |= UInt16(self.RCODE) << 0
        data.append(contentsOf: flags.bytes)
        
        data.append(contentsOf: UInt16(self.Questions.count).bytes)
        data.append(contentsOf: UInt16(self.Answers.count).bytes)
        data.append(contentsOf: UInt16(self.Authoritys.count).bytes)
        data.append(contentsOf: UInt16(self.Additionals.count).bytes)
        
        var domainOffset = [String: UInt16]()
        
        for question in Questions {
            
            encodeDomain(question.domain, data: &data, domainOffset: &domainOffset)
            
            data.append(contentsOf: question.qtype.rawValue.bytes)
            data.append(contentsOf: question.qclass.bytes)
        }
        
        for answer in Answers {
            encodeResourceRecord(answer, data: &data, domainOffset: &domainOffset)
        }

        for authority in Authoritys {
            encodeResourceRecord(authority, data: &data, domainOffset: &domainOffset)
        }

        for additional in Additionals {
            encodeResourceRecord(additional, data: &data, domainOffset: &domainOffset)
        }
        return data
    }
    
}

// MARK:  - Question, ResourceRecord
public extension PKDNSPacket {
    
    /// 查询问题
    struct Question: Sendable {
        public let domain: String
        public let qtype: QueryType
        public let qclass: UInt16
        
        public init(domain: String, qtype: QueryType, qclass: UInt16) {
            self.domain = domain
            self.qtype = qtype
            self.qclass = qclass
        }
    }
    
    /// 资源记录
    struct ResourceRecord: Sendable {
        public let domain: String
        public let qtype: QueryType
        public let qclass: UInt16
        public let ttl: UInt32
        public let rdlength: UInt16
        public let rdata: Data
        
        /// 资源内容
        public var content: Content
        
        public init(domain: String, qtype: QueryType, qclass: UInt16, ttl: UInt32, rdlength: UInt16, rdata: Data, content: Content) {
            self.domain = domain
            self.qtype = qtype
            self.qclass = qclass
            self.ttl = ttl
            self.rdlength = rdlength
            self.rdata = rdata
            self.content = content
        }
    }
}


// MARK: - ResourceRecord Content
public extension PKDNSPacket.ResourceRecord {
    
    struct SOA: Sendable {
        public let mname: String
        public let rname: String
        public let serial: UInt32
        public let refresh: UInt32
        public let retry: UInt32
        public let expire: UInt32
        public let minimum: UInt32
        
        init(data: Data, offset: inout Int) throws {
            self.mname = try readDomainName(data: data, offset: &offset)
            self.rname = try readDomainName(data: data, offset: &offset)
            
            self.serial = UInt32(try data.sub(start: offset, end: offset+4))
            offset += 4
            
            self.refresh = UInt32(try data.sub(start: offset, end: offset+4))
            offset += 4
            
            self.retry = UInt32(try data.sub(start: offset, end: offset+4))
            offset += 4
            
            self.expire = UInt32(try data.sub(start: offset, end: offset+4))
            offset += 4
            
            self.minimum = UInt32(try data.sub(start: offset, end: offset+4))
            offset += 4
        }
    }
    
    struct MX: Sendable {
        public let priority: UInt16
        public let host: String
        init(data: Data, offset: inout Int) throws {
            self.priority = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            self.host = try readDomainName(data: data, offset: &offset)
        }
    }
    
    struct SRV: Sendable {
        public let priority: UInt16
        public let weight: UInt16
        public let port: UInt16
        public let target: String
        init(data: Data, offset: inout Int) throws {
            self.priority = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            self.weight = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            self.port = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            self.target = try readDomainName(data: data, offset: &offset)
        }
    }
    
    enum Content: Sendable {
        case none
        case A(address: String)
        case NS(msdname: String)
        case CNAME(cname: String)
        case SOA(soa: SOA)
        case PTR(ptrdname: String)
        case HINFO(cpu: String, os: String)
        case MX(mx: MX)
        case TEXT(txt: String)
        case AAAA(address: String)
        case SRV(srv: SRV)
    }
}


// MARK: - QueryType
public extension PKDNSPacket {
    /**
     A    1    RFC 1035    IPv4地址记录    传回一个32位的IPv4地址，最常用于映射主机名称到IP地址，但也用于DNSBL（RFC 1101）等。
     AAAA    28    RFC 3596    IPv6地址记录    传回一个128位的IPv6地址，最常用于映射主机名称到IP地址。
     AFSDB    18    RFC 1183    AFS文件系统    （Andrew File System）数据库核心的位置，于域名以外的 AFS 客户端常用来联系 AFS 核心。这个记录的子类型是被过时的的 DCE/DFS（DCE Distributed File System）所使用。
     APL    42    RFC 3123    地址前缀列表    指定地址栏表的范围，例如：CIDR 格式为各个类型的地址（试验性）。
     CAA    257    RFC 6844    权威认证授权    DNS认证机构授权，限制主机/域的可接受的CA
     CDNSKEY    60    RFC 7344    子关键记录    关键记录记录的子版本，用于转移到父级
     CDS    59    RFC 7344    子委托签发者    委托签发者记录的子版本，用于转移到父级
     CERT    37    RFC 4398    证书记录    存储 PKIX、SPKI、PGP等。
     CNAME    5    RFC 1035    规范名称记录    一个主机名字的别名：域名系统将会继续尝试查找新的名字。
     DHCID    49    RFC 4701    DHCP（动态主机设置协议）标识符    用于将 FQDN 选项结合至 DHCP。
     DLV    32769    RFC 4431    DNSSEC（域名系统安全扩展）来源验证记录    为不在DNS委托者内发布DNSSEC的信任锚点，与 DS 记录使用相同的格式，RFC 5074 介绍了如何使用这些记录。
     DNAME    39    RFC 2672    代表名称    DNAME 会为名称和其子名称产生别名，与 CNAME 不同，在其标签别名不会重复。但与 CNAME 记录相同的是，DNS将会继续尝试查找新的名字。
     DNSKEY    48    RFC 4034    DNSSEC所用公钥记录    于DNSSEC内使用的公钥，与 KEY 使用相同格式。
     DS    43    RFC 4034    委托签发者    包含DNSKEY的散列值，此记录用于鉴定DNSSEC已授权区域的签名密钥。
     HIP    55    RFC 5205    主机鉴定协议    将端点标识符及IP 地址定位的分开的方法。
     HTTPS    65    IETF草案 （页面存档备份，存于互联网档案馆）    绑定HTTPS    与创建HTTPS连接相关的记录。详见DNSOP工作组和阿卡迈科技发布的草案。
     IPSECKEY    45    RFC 4025    IPSEC 密钥    与 IPSEC 同时使用的密钥记录。
     KEY    25    RFC 2535[1]RFC 2930[2]    密钥记录    只用于 SIG(0)（RFC 2931）及 TKEY（RFC 2930）。[3]RFC 3455 否定其作为应用程序键及限制DNSSEC的使用。[4]RFC 3755 指定了 DNSKEY 作为DNSSEC的代替。[5]
     LOC记录（LOC record）    29    RFC 1876    位置记录    将一个域名指定地理位置。
     MX记录（MX record）    15    RFC 1035    电邮交互记录    引导域名到该域名的邮件传输代理（MTA, Message Transfer Agents）列表。
     NAPTR记录（NAPTR record）    35    RFC 3403    命名管理指针    允许基于正则表达式的域名重写使其能够作为 URI、进一步域名查找等。
     NS    2    RFC 1035    名称服务器记录    委托DNS区域（DNS zone）使用已提供的权威域名服务器。
     NSEC    47    RFC 4034    下一个安全记录    DNSSEC 的一部分 — 用来表示特定域名的记录并不存在，使用与 NXT（已过时）记录的格式。
     NSEC3    50    RFC 5155    下一个安全记录第三版    DNSSEC 的一部分 — 用来表示特定域名的记录并不存在。
     NSEC3PARAM    51    RFC 5155    NSEC3 参数    与 NSEC3 同时使用的参数记录。
     OPENPGPKEY    61    RFC 7929    OpenPGP公钥记录    基于DNS的域名实体认证方法，用于使用OPENPGPKEY DNS资源记录在特定电子邮件地址的DNS中发布和定位OpenPGP公钥。
     PTR    12    RFC 1035    指针记录    引导至一个规范名称（Canonical Name）。与 CNAME 记录不同，DNS“不会”进行进程，只会传回名称。最常用来执行反向DNS查找，其他用途包括引作 DNS-SD。
     RRSIG    46    RFC 4034    DNSSEC 证书    用于DNSSEC，存放某记录的签名，与 SIG 记录使用相同的格式。
     RP    17    RFC 1183    负责人    有关域名负责人的信息，电邮地址的 @ 通常写为 a。
     SIG    24    RFC 2535    证书    SIG(0)（RFC 2931）及 TKEY（RFC 2930）使用的证书。[5]RFC 3755 designated RRSIG as the replacement for SIG for use within DNSSEC.[5]
     SOA    6    RFC 1035    权威记录的起始    指定有关DNS区域的权威性信息，包含主要名称服务器、域名管理员的电邮地址、域名的流水式编号、和几个有关刷新区域的定时器。
     SPF    99    RFC 4408    SPF 记录    作为 SPF 协议的一部分，优先作为先前在 TXT 存储 SPF 数据的临时做法，使用与先前在 TXT 存储的格式。
     SRV记录（SRV record）    33    RFC 2782    服务定位器    广义为服务定位记录，被新式协议使用而避免产生特定协议的记录，例如：MX 记录。
     SSHFP    44    RFC 4255    SSH 公共密钥指纹    DNS 系统用来发布 SSH 公共密钥指纹的资源记录，以用作辅助验证服务器的真实性。
     TA    32768    无    DNSSEC 可信权威    DNSSEC 一部分无签订 DNS 根目录的部署提案，使用与 DS 记录相同的格式[6][7]。
     TKEY记录（TKEY record）    249    RFC 2930    秘密密钥记录    为TSIG提供密钥材料的其中一类方法，that is 在公共密钥下加密的 accompanying KEY RR。[8]
     TSIG    250    RFC 2845    交易证书    用以认证动态更新（Dynamic DNS）是来自合法的客户端，或与 DNSSEC 一样是验证回应是否来自合法的递归名称服务器。[9]
     TXT    16    RFC 1035    文本记录    最初是为任意可读的文本 DNS 记录。自1990年起，些记录更经常地带有机读数据，以 RFC 1464 指定：机会性加密（opportunistic encryption）、Sender Policy Framework（虽然这个临时使用的 TXT 记录在 SPF 记录推出后不被推荐）、DomainKeys、DNS-SD等。
     URI    256    RFC 7553    统一资源标识符    可用于发布从主机名到URI的映射。
     */
    enum QueryType: UInt16, Sendable {
        case none = 0
        case A = 1
        case NS = 2
        case CNAME = 5
        case SOA = 6
        case WKS = 11
        case PTR = 12
        case HINFO = 13
        case MX = 15
        case TXT = 16
        case AAAA = 28
        case SRV = 33
        case OPT = 41
        case DS = 43
        case DNSKYE = 48
        case AXFR = 252
        case ANY = 255
        case CAA = 257
        
        public var sort: UInt16 {
            switch self {
            case .A:
                return 9999
            case .AAAA:
                return 9998
            default:
                return self.rawValue
            }
        }
        
        public var toStr: String {
            switch self {
            case .none:
                return ""
            case .A:
                return "A"
            case .NS:
                return "NS"
            case .CNAME:
                return "CNAME"
            case .SOA:
                return "SOA"
            case .WKS:
                return "WKS"
            case .PTR:
                return "PTR"
            case .HINFO:
                return "HINFO"
            case .MX:
                return "MX"
            case .TXT:
                return "TXT"
            case .AAAA:
                return "AAAA"
            case .SRV:
                return "SRV"
            case .OPT:
                return "OPT"
            case .DS:
                return "DS"
            case .DNSKYE:
                return "DNSKYE"
            case .AXFR:
                return "AXFR"
            case .ANY:
                return "ANY"
            case .CAA:
                return "CAA"
            }
        }
    }
    
    
}

/// 解析记录
/// - Parameters:
///   - data:
///   - count:
///   - offset:
/// - Returns:
fileprivate func parseRecords(data: Data, count: Int, offset: inout Int) throws -> [PKDNSPacket.ResourceRecord] {
    var records = [PKDNSPacket.ResourceRecord]()
    for _ in 0 ..< count {
        let domain = try readDomainName(data: data, offset: &offset)
        
        let qtype = UInt16(try data.sub(start: offset, end: offset+2))
        let type = PKDNSPacket.QueryType(rawValue: qtype) ?? .none
        offset += 2
        
        let qclass = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        let ttl = UInt32(try data.sub(start: offset, end: offset+4))
        offset += 4
        
        let rdlength = UInt16(try data.sub(start: offset, end: offset+2))
        offset += 2
        
        // 记录数据offset
        var dataOffset = offset
        
        let rddata = try data.sub(start: offset, end: offset+Int(rdlength))
        offset += Int(rdlength)
        
        var content: PKDNSPacket.ResourceRecord.Content = .none
        switch type {
        case .A:
            content = .A(address: String(fromIP4: rddata.reversed()) ?? "")
        case .NS:
            content = .NS(msdname: try readDomainName(data: data, offset: &dataOffset))
        case .CNAME:
            content = .CNAME(cname: try readDomainName(data: data, offset: &dataOffset))
        case .SOA:
            content = .SOA(soa: try .init(data: data, offset: &dataOffset))
        case .WKS:
            break
        case .PTR:
            content = .PTR(ptrdname: try readDomainName(data: data, offset: &dataOffset))
        case .HINFO:
            content = .HINFO(cpu: try readDomainName(data: data, offset: &dataOffset), os: try readDomainName(data: data, offset: &offset))
        case .MX:
            content = .MX(mx: try .init(data: data, offset: &dataOffset))
        case .TXT:
            content = .TEXT(txt: String(data: rddata, encoding: .utf8) ?? "")
        case .AAAA:
            content = .AAAA(address: String(fromIP6: [UInt8](rddata)) ?? "")
        case .SRV:
            content = .SRV(srv: try .init(data: data, offset: &dataOffset))
        default:
            break
        }

        
        records.append(.init(domain: domain,
                             qtype: type,
                             qclass: qclass,
                             ttl: ttl,
                             rdlength: rdlength,
                             rdata: rddata,
                             content: content))
    }
    return records
}

/// 读取域名支持迭代读取
/// - Parameters:
///   - data:
///   - offset:
/// - Returns:
fileprivate func readDomainName(data: Data, offset: inout Int) throws -> String {
    
    var labels: [String] = []
    while true {
        
        let len = try data.at(offset)
        if len & 0xC0 == 0xC0 {
            /// 指针偏移
            let n = UInt16(try data.sub(start: offset, end: offset+2))
            offset += 2
            
            var suboffset = data.startIndex + Int(n & 0x3FFF)
            labels.append(try readDomainName(data: data, offset: &suboffset))
            break
            
        } else if len > 0 {
            /// 正常读取
            offset += 1
            
            let end = offset + Int(len)
            if let label = String(data: try data.sub(start: offset, end: end), encoding: .utf8) {
                labels.append(label)
            }
            
            offset = end
            
        } else {
            /// 结束
            offset += 1
            break
        }
    }
    
    return labels.joined(separator: ".")
}


fileprivate extension Data {
    func at(_ offset: Int) throws -> UInt8 {
        guard offset < self.endIndex else {
            throw PKDNSPacket.ParseError.invaliedData
        }
        
        return self[offset]
    }
    
    func sub(start: Int, end: Int) throws -> Data {
        guard start >= self.startIndex && end <= self.endIndex  else {
            throw PKDNSPacket.ParseError.invaliedData
        }
        
        return self[start ..< end]
    }
}
