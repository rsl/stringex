module LuckySneaks
  module StringExtensions
    # Returns the string converted (via Textile/RedCloth) to HTML format or
    # self if Redcloth is not available
    # 
    # Using :lite argument will cause RedCloth to not wrap the HTML in a container
    # P element, which is useful behavior for generating header element text, etc
    def to_html(lite_mode = false)
      if defined?(RedCloth)
        if lite_mode
          RedCloth.new(self, [:lite_mode]).to_html
        else
          if self =~ /<pre>/
            RedCloth.new(self).to_html.tr("\t", "")
          else
            RedCloth.new(self).to_html.tr("\t", "").gsub(/\n\n/, "")
          end
        end
      else
        self
      end
    end
    
    # Create a URI-friendly representation of the string
    def to_url
      downcase.remove_formatting.replace_whitespace("-").collapse("-")
    end
    
    # Performs multiple text manipulations. Essentially a shortcut for typing them all.
    def remove_formatting
      to_ascii.strip_html_tags.convert_accented_entities.convert_misc_entities.convert_misc_characters
    end

    # Removes HTML tags from text. This code is simplified from Tobias Luettke's RegEx
    # in Typo (http://typosphere.org)
    def strip_html_tags(leave_whitespace = false)
      name = /[\w:_-]+/
      value = /([A-Za-z0-9]+|('[^']*?'|"[^"]*?"))/
      attr = /(#{name}(\s*=\s*#{value})?)/
      rx = /<[!\/?\[]?(#{name}|--)(\s+(#{attr}(\s+#{attr})*))?\s*([!\/?\]]+|--)?>/
      (leave_whitespace) ?  gsub(rx, "").strip : gsub(rx, "").gsub(/\s+/, " ").strip
    end

    # Converts HTML entities (like <tt>&agrave;</tt>) into the respective non-accented letters (<tt>a</tt>)
    def convert_accented_entities
      gsub(/&([A-Za-z])(grave|acute|circ|tilde|uml|ring|cedil|slash);/, '\1')
    end

    # Converts HTML entities (taken from common Textile/RedCloth formattings) into plain text formats
    def convert_misc_entities
      dummy = dup
      {
        "#822[01]" => "\"",
        "#821[67]" => "'",
        "#8230" => "...",
        "#8211" => "-",
        "#8212" => "--",
        "#215" => "x",
        "gt" => ">",
        "lt" => "<",
        "(#8482|trade)" => "(tm)",
        "(#174|reg)" => "(r)",
        "(#169|copy)" => "(c)",
        "(#38|amp)" => "and",
        "nbsp" => " ",
        "(#162|cent)" => " cent",
        "(#163|pound)" => " pound",
        "(#188|frac14)" => "one fourth",
        "(#189|frac12)" => "half",
        "(#190|frac34)" => "three fourths",
        "(#176|deg)" => " degrees"
      }.each do |textiled, normal|
        dummy.gsub!(/&#{textiled};/, normal)
      end
      dummy.gsub(/&[^;]+;/, "")
    end

    # Converts various common plaintext characters to a more URI-friendly representation
    def convert_misc_characters
      dummy = dup
      {
        /\s*&\s*/ => "and",
        /\s*#/ => "number",
        /\s*@\s*/ => "at",
        /(\S|^)\.(\S)/ => '\1 dot \2',
        /(\s|^)\$(\d*)(\s|$)/ => '\2 dollars',
        /\s*\*\s*/ => "star",
        /\s*%\s*/ => "percent",
        /\s*(\\|\/)\s*/ => "slash"
      }.each do |found, replaced|
        replaced = " #{replaced} " unless replaced =~ /\\1/
        dummy.gsub!(found, replaced)
      end
      dummy = dummy.gsub(/(^|\w)'(\w|$)/, '\1\2').gsub(/[\.,:;()\[\]\/\?!\^'"_]/, "")
    end

    # Replace runs of whitespace in string. Defaults to a single space but any replacement
    # string may be specified as an argument.
    def replace_whitespace(replace = " ")
      gsub(/\s+/, replace)
    end

    # Removes specified character from the beginning and/or end of the string and then performs
    # <tt>String#squeeze(character)</tt>, condensing runs of the character within the string
    def collapse(character = " ")
      sub(/^#{character}*/, "").sub(/#{character}*$/, "").squeeze(character)
    end
  end
end

String.send :include, LuckySneaks::StringExtensions