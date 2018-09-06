#!/bin/sh

set -eu

# Their real address
THEIR_REAL_ADDRESS=$1

# Single digit 0-255
OUR_SUBNET_START=$2
THEIR_SUBNET_START=$3


OUR_REAL_ADDRESS=$(ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n')
OUR_SUBNET=10.0.${OUR_SUBNET_START}
THEIR_SUBNET=10.0.${THEIR_SUBNET_START}

sudo apt install -y strongswan

sudo ip address add ${OUR_SUBNET}.1/24 dev ens3 label ens3:test
sudo ip route del ${THEIR_SUBNET}.0/24
sudo ip route add ${THEIR_SUBNET}.0/24 dev ens3 src ${OUR_SUBNET}.1

sudo cat << EOF > /etc/ipsec.conf
# Test config
config setup

conn %default
	ikelifetime=60m
	keylife=20m
	rekeymargin=3m
	keyingtries=1
	keyexchange=ikev2
	mobike=no
	
conn net-net
	left=${OUR_REAL_ADDRESS}
	leftcert=hostacert.pem
	leftsubnet=${OUR_SUBNET}.0/24
	leftid=@leftgw
	leftfirewall=yes
	right=${THEIR_REAL_ADDRESS}
	rightsubnet=${THEIR_SUBNET}.0/24
	rightid=@rightgw
	auto=add
EOF

sudo cat << EOF > /etc/ipsec.secrets
# Test config
: RSA hostakey.pem
EOF

sudo cat << EOF > /etc/ipsec.d/certs/5a23788d.0
-----BEGIN CERTIFICATE-----
MIIDbTCCAlWgAwIBAgIJAIQnwC0gy/r0MA0GCSqGSIb3DQEBBQUAME0xCzAJBgNV
BAYTAlVTMRAwDgYDVQQIDAdBcml6b25hMRAwDgYDVQQKDAdUZXN0bGliMQ0wCwYD
VQQLDARUZXN0MQswCQYDVQQDDAJDQTAeFw0xNTA1MjkxMzU4MjNaFw0yOTAyMDQx
MzU4MjNaME0xCzAJBgNVBAYTAlVTMRAwDgYDVQQIDAdBcml6b25hMRAwDgYDVQQK
DAdUZXN0bGliMQ0wCwYDVQQLDARUZXN0MQswCQYDVQQDDAJDQTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAMq/39Ulya1cFRcoU1kmI1ZtyeoMxl/GS64y
zZAY5WX0OS0EJ7S8E1ALpFm6DjcbGmCsh0FBCKD47VQi0APK/lB3KQSG3fovA+kR
7sOWideAl2T/LDas/+UxAJ4eAzFoV4D/zQycKpxho5H1gFbx8l8hAmo8KDVAUzRn
Sk/a1kJ7V2WzzumbVqYwnZWWKfEnfzdHvhIbM4J3ChIbg3isD27MODHrKM9izud4
+h5ikvX+0EHvQk1GRn8vTbQaEA51mdzqxiMWU/9Puuh9575UKEubkMBez2dfTO2A
wZ5UN9KOqwJjGDqm7udoYEVYRuyfKY8hdPWWyVRhXwBAYdbC6TUCAwEAAaNQME4w
HQYDVR0OBBYEFIH/2SOMgc0sm7MrmYfSDSm3AiLRMB8GA1UdIwQYMBaAFIH/2SOM
gc0sm7MrmYfSDSm3AiLRMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEB
ADE2csdxcwgVkLPlr3/cypkuNFrbQHB4vwRVUS87uQ7/vKzp+Wasn0k7speyiTFQ
nITVD6U3riVuoPhdVUC35WJLgIJbxNU4wjwXWtrzlBGZ8gatYdH86oADdXmmWYt8
eGukA/Z67cjTARnKC1GO8drrJ3FNAMCy2aDifueRbJhO7Eyok4ur7QcktBZ4TPVm
rwmiBonAjuFMcFEaQam8rjdS5YBItdMu3DqQXAUHhaZ6Kww8jkIxBhW/gHrWOJLb
wSebnFFif9dWq+44VkDxqlquQqEvE1cztzjalDhxFwzdzqCH0XDbrDy6JDhKcpBF
CTyJNNseEBx0O9XmvmYlZ3o=
-----END CERTIFICATE-----
EOF

sudo cat << EOF > /etc/ipsec.d/certs/hostacert.pem
-----BEGIN CERTIFICATE-----
MIICjTCCAXUCAQEwDQYJKoZIhvcNAQEFBQAwTTELMAkGA1UEBhMCVVMxEDAOBgNV
BAgMB0FyaXpvbmExEDAOBgNVBAoMB1Rlc3RsaWIxDTALBgNVBAsMBFRlc3QxCzAJ
BgNVBAMMAkNBMB4XDTE1MDUyOTEzNTkzNFoXDTI5MDIwNDEzNTkzNFowUDELMAkG
A1UEBhMCVVMxEDAOBgNVBAgMB0FyaXpvbmExEDAOBgNVBAoMB1Rlc3RsaWIxDTAL
BgNVBAsMBFRlc3QxDjAMBgNVBAMMBWhvc3RhMIGfMA0GCSqGSIb3DQEBAQUAA4GN
ADCBiQKBgQC6juz8j1iUb4jmTXGKvOFmCLXelq8keHK8obPoQjaADZL2EeQqGU88
dPNoXTROdr5WJhgqwRt4UE8TvGNjULtuFlMFE97SzGE/MU3Opc/QzZKAlhjkE1nK
D+AXPcp/FMitGAWsxVGWiX64l9wtur3jAHgdoitPds1kSNNxbe99RQIDAQABMA0G
CSqGSIb3DQEBBQUAA4IBAQAPllPcngLy+/yMhbkWzZGxBrMuM3GfCDw+CZGkE/5V
XiB5021bRrpkzvTSjWTu2S7SxGmcuz+iUMTaz+TpTMa1KDYXN8Hvh7QomlYwVlr5
s2YgKkNPVdBAh7mn9CZ8Fu+987KRcyW05oly6al+jAJnScTyMCtWzp1qpsPMOsrK
db1HCTYHUwo8iT8XMaGkk4ZmDGL1MHojDh/jqxtipL39LJeFKUbWPHWgwcQ10nQk
ZCBh6NkEOz4GyL95jZUrW83IilTSCu1SfKQSG8UKKZJVbsOoGmMIgNWy+r0xKsP+
u5B/OUmw8K6MHdzgvyVp5qjVljqfBlUBsmm8TkfMbR61
-----END CERTIFICATE-----
EOF

sudo cat << EOF > /etc/ipsec.d/certs/hostakey.pem
-----BEGIN PRIVATE KEY-----
MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALqO7PyPWJRviOZN
cYq84WYItd6WryR4cryhs+hCNoANkvYR5CoZTzx082hdNE52vlYmGCrBG3hQTxO8
Y2NQu24WUwUT3tLMYT8xTc6lz9DNkoCWGOQTWcoP4Bc9yn8UyK0YBazFUZaJfriX
3C26veMAeB2iK092zWRI03Ft731FAgMBAAECgYAPykcevVdHAQW6UHW6w2/kffo+
w8xBLvyvIJSkpO4N+pgkwbDpK0k8mb18aN8jgQNtMT48aCnWDh4TUo+q+UtTyciJ
zwnJqzedbVm3nkLpqkNAN1HAOjln9FoPomymU0NgigmQqTudteeOA6qn3GcVCwUK
QHmewAbvfU3WHF6WwQJBAPYXHnxiFLtdHPrxuBc9gr9h6OnC4ItfvAVI2MG5/3da
i9qlLTYrIjBGohXyayGAFP3bgjdm4exEC4MxhJJzjbUCQQDCEhtQ2T4irc0oUriM
VO1oMDN/wW2iNR62jImkbvs2KGeZ29+/UbNd6gzaB99ZGBQntp+vci0hazuATG8t
sWtRAkEAwsNxYUfO2KrM8N61r88C160JxVhyllviVtxckJZAVZnX7eekbKaenE6K
oYwGtbDE7FT6LhbC31bLNb3PColhsQJALxh1yIjvqzrCLqbkYim58y6/UKGAGX0K
lwJD5MOJ8vqbKZtSEPuiq4fA1qhSayyMt5Z56fmrOhDrv5bM5CnKAQJBAMSlGYIt
3QpckAAMz/WmJcyEvTTCQhOkFG8VC7Y/25nru8irgJCyL1V9xgZrO1DODsz5xnMG
H0jOhDdJBKpns4w=
-----END PRIVATE KEY-----
EOF

sudo aa-enabled

echo "
Strongswan set up. To start the service:
    systemctl start strongswan

Make sure they exist:
    ping -n -c 1 -w 4 -- ${THEIR_REAL_ADDRESS}

Make sure the VPN is up:
    ping -n -c 1 -w 4 -- ${THEIR_SUBNET}.1

Teardown:
    systemctl stop strongswan
    ip address del ${OUR_SUBNET}.1/24 dev ens3 label ens3:test
"
