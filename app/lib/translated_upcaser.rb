module TranslatedUpcaser
  def upcase_name
		globalize_attribute_names.each do |attr_name|
			val = send(attr_name)
			send("#{attr_name}=".to_sym, val.upcase) unless val.blank?
		end
	end
end