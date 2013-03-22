# encoding: UTF-8

module Stringex
  module Localization
    module ConversionExpressions
      CHARACTERS =  {
        :and           => /\s*&\s*/,
        :at            => /\s*@\s*/,
        :degrees       => /\s*°\s*/,
        :divide        => /\s*÷\s*/,
        :dot           => /(\S|^)\.(\S)/,
        :ellipsis      => /\s*\.{3,}\s*/,
        :equals        => /\s*=\s*/,
        :number        => /\s*#/,
        :percent       => /\s*%\s*/,
        :plus          => /\s*\+\s*/,
        :slash         => /\s*(\\|\/|／)\s*/,
        :star          => /\s*\*\s*/,
      }

      CURRENCIES = {
        :dollars       => /(?:\s|^)\$(\d*)(?:\s|$)/,
        :dollars_cents => /(?:\s|^)\$(\d+)\.(\d+)(?:\s|$)/,
        :euros         => /(?:\s|^)€(\d*)(?:\s|$)/u,
        :euros_cents   => /(?:\s|^)€(\d+)\.(\d+)(?:\s|$)/u,
        :pounds        => /(?:\s|^)£(\d*)(?:\s|$)/u,
        :pounds_pence  => /(?:\s|^)£(\d+)\.(\d+)(?:\s|$)/u,
        :yen           => /(?:\s|^)¥(\d*)(?:\s|$)/u,
      }

      HTML_ENTITIES = {
        :amp          => '(#38|amp)',
        :cent         => '(#162|cent)',
        :copy         => '(#169|copy)',
        :deg          => '(#176|deg)',
        :divide       => "(#247|divide)",
        :double_quote => '(#34|#822[012]|quot|ldquo|rdquo|dbquo)',
        :ellipsis     => '(#8230|hellip)',
        :en_dash      => '(#8211|ndash)',
        :em_dash      => '(#8212|emdash)',
        :frac14       => '(#188|frac14)'.
        :frac12       => '(#189|frac12)',
        :frac34       => '(#190|frac34)',
        :gt           => '(#62|gt)',
        :lt           => '(#60|lt)',
        :nbsp         => '(#160|nbsp)',
        :pound        => '(#163|pound)',
        :reg          => '(#174|reg)',
        :single_quote => '(#39|#821[678]|apos|lsquo|rsquo|sbquo)',
        :times        => '(#215|times)',
        :trade        => '(#8482|trade)',
        :yen          => '(#165|yen)',
      }

      HTML_TAG = Proc.new(){
        name = /[\w:_-]+/
        value = /([A-Za-z0-9]+|('[^']*?'|"[^"]*?"))/
        attr = /(#{name}(\s*=\s*#{value})?)/
        /<[!\/?\[]?(#{name}|--)(\s+(#{attr}(\s+#{attr})*))?\s*([!\/?\]]+|--)?>/
      }.call

      # Ordered by denominator then numerator of the value
      VULGAR_FRACTIONS = {
        :half          => '(&#189;|&frac12;|½)',
        :one_third     => '(&#8531;|⅓)',
        :two_thirds    => '(&#8532;|⅔)',
        :one_fourth    => '(&#188;|&frac14;|¼)',
        :three_fourths => '(&#190;|&frac34;|¾)',
        :one_fifth     => '(&#8533;|⅕)',
        :two_fifths    => '(&#8534;|⅖)',
        :three_fifths  => '(&#8535;|⅗)',
        :four_fifths   => '(&#8536;|⅘)',
        :one_sixth     => '(&#8537;|⅙)',
        :five_sixths   => '(&#8538;|⅚)',
        :one_eighth    => '(&#8539;|⅛)',
        :three_eighths => '(&#8540;|⅜)',
        :five_eighths  => '(&#8541;|⅝)',
        :seven_eighths => '(&#8542;|⅞)',
      }

      WHITESPACE = /\s+/
    end
  end
end
