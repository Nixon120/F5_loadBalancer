{
  "schemaVersion": "1.0.0",
  "class": "Device",
  "async": true,
  "label": "Onboard BIG-IP",
  "Common": {
    "class": "Tenant",
    "mySystem": {
      "class": "System",
      "hostname": "${hostname}"
    },
    "myDns": {
      "class": "DNS",
      "nameServers": [
        "8.8.8.8", "169.254.169.253"
      ],
      "search": [
        "f5.com"
      ]
    },
    "myNtp": {
      "class": "NTP",
      "servers": [
       "169.254.169.123"
      ],
      "timezone": "UTC"
    },
    "external": {
      "class": "VLAN",
      "tag": 4093,
      "mtu": 1500,
      "interfaces": [
        {
          "name": "1.1",
          "tagged": false
        }
      ],
      "cmpHash": "dst-ip"
    },
    "external-selfip": {
      "class": "SelfIp",
      "address": "${self-ip1}/24",
      "vlan": "external",
      "allowService": "none",
      "trafficGroup": "traffic-group-local-only"
    },
    "default": {
      "class": "Route",
      "gw": "${gateway}",
      "network": "default",
      "mtu": 1500
    },
    "internal": {
      "class": "VLAN",
      "tag": 4094,
      "mtu": 1500,
      "interfaces": [
        {
          "name": "1.2",
          "tagged": false
        }
      ],
      "cmpHash": "dst-ip"
    },
    "internal-selfip": {
      "class": "SelfIp",
      "address": "${self-ip2}/24",
      "vlan": "internal",
      "allowService": "default",
      "trafficGroup": "traffic-group-local-only"
    }
  }
}
