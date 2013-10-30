package {
	"rubygems":
		ensure => installed,
		provider => pkgutil,
}

package {
	["rest-client", "net-ldap"]:
		ensure => installed,
		provider => gem,
		require => Package["rubygems"],
}
