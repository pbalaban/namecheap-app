class String
  def sanitize_spaces
    self.strip.gsub(/\s{2,}/, ' ')
  end

  def remove_dollar
    self.strip.gsub(/\$/, '')
  end
end
