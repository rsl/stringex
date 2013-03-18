module Stringex
  module Localization
    module DefaultConversions
      CHARACTERS =  {
        :and           => "and",
        :number        => "number",
        :at            => "at",
        :dot           => '\1 dot \2',
        :dollars       => '\1 dollars',
        :dollars_cents => '\1 dollars \2 cents',
        :pounds        => '\1 pounds',
        :pounds_pence  => '\1 pounds \2 pence',
        :euros         => '\1 euros',
        :euros_cents   => '\1 euros \2 cents',
        :yen           => '\1 yen',
        :star          => "star",
        :percent       => "percent",
        :equals        => "equals",
        :plus          => "plus",
        :divide        => "divide",
        :degrees       => "degrees",
        :ellipsis      => "dot dot dot",
        :slash         => "slash"
      }

      HTML_ENTITIES = {
        :double_quote => "\"",
        :single_quote => "'",
        :ellipsis     => "...",
        :en_dash      => "-",
        :em_dash      => "--",
        :times        => "x",
        :gt           => ">",
        :lt           => "<",
        :trade        => "(tm)",
        :reg          => "(r)",
        :copy         => "(c)",
        :amp          => "and",
        :nbsp         => " ",
        :cent         => " cent",
        :pound        => " pound",
        :frac14       => "one fourth",
        :frac12       => "half",
        :frac34       => "three fourths",
        :divide       => "divide",
        :deg          => " degrees "
      }

      TRANSLITERATIONS = {}

      VULGAR_FRACTIONS = {
        :one_fourth    => "one fourth",
        :half          => "half",
        :three_fourths => "three fourths",
        :one_third     => "one third",
        :two_thirds    => "two thirds",
        :one_fifth     => "one fifth",
        :two_fifths    => "two fifths",
        :three_fifths  => "three fifths",
        :four_fifths   => "four fifths",
        :one_sixth     => "one sixth",
        :five_sixths   => "five sixths",
        :one_eighth    => "one eighth",
        :three_eighths => "three eighths",
        :five_eighths  => "five eighths",
        :seven_eighths => "seven eighths"
      }

      class << self
        %w{characters html_entities transliterations vulgar_fractions}.each do |conversion_type|
          define_method conversion_type do
            const_get conversion_type.upcase
          end
        end
      end
    end
  end
end
