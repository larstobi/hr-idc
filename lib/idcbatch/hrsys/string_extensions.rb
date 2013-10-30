class String
    def to_date
        Date.parse(self)
    end

    def valid_email?
        if (self =~ %r{
            [^@]+       # Before at characters
            @           # Separating at character
            [^.]+       # Domain name middle
            \.          # Period before top domain
            .+          # Top domain name or additional domains
            }xi         # Case insensitive
            ) == 0
            true
        else
            false
        end
    end
end
