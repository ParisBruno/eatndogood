module TranslatedUpcaser
  def upcase_name
		names = globalize_attribute_names.select{|x| x.to_s.include?('name')}
		names.each do |attr_name|
			val = send(attr_name)
			send("#{attr_name}=".to_sym, val.upcase) unless val.blank?
		end
	end
end