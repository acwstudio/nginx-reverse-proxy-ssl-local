init:
	mkcert -key-file $(PWD)/etc/ssl/private/mkcert-key.pem -cert-file $(PWD)/etc/ssl/private/mkcert.pem $(DOMENS)