module Stringex
  module Localization
    module DefaultConversions
      CHARACTERS =  {
        :and           => "and",
        :at            => "at",
        :degrees       => "degrees",
        :divide        => "divide",
        :dot           => '\1 dot \2',
        :ellipsis      => "dot dot dot",
        :equals        => "equals",
        :number        => "number",
        :percent       => "percent",
        :plus          => "plus",
        :slash         => "slash",
        :star          => "star",
      }

      CURRENCIES = {
        :dollars       => '\1 dollars',
        :dollars_cents => '\1 dollars \2 cents',
        :euros         => '\1 euros',
        :euros_cents   => '\1 euros \2 cents',
        :pounds        => '\1 pounds',
        :pounds_pence  => '\1 pounds \2 pence',
        :yen           => '\1 yen',
      }

      HTML_ENTITIES = {
        :amp          => "and",
        :cent         => " cents",
        :copy         => "(c)",
        :deg          => " degrees ",
        :divide       => "divide",
        :double_quote => "\"",
        :ellipsis     => "...",
        :en_dash      => "-",
        :em_dash      => "--",
        :frac14       => "one fourth",
        :frac12       => "half",
        :frac34       => "three fourths",
        :gt           => ">",
        :lt           => "<",
        :nbsp         => " ",
        :pound        => " pound",
        :reg          => "(r)",
        :single_quote => "'",
        :times        => "x",
        :trade        => "(tm)",
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
        :seven_eighths => "seven eighths",
      }

      class << self
        %w{characters currencies html_entities transliterations vulgar_fractions}.each do |conversion_type|
          define_method conversion_type do
            const_get conversion_type.upcase
          end
        end
      end
    end
  end
end
