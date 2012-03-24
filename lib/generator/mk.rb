module Generator
  
  module MakeFile
    
    def self.make
      model_name = Generator.config[:model_name]
      synthesize = []
      mapping = []
      decoders = []
      encoders = []
      Generator.properties.each{|key, value| synthesize << key }
      Generator.properties.each{|key, value| mapping << "	@\"#{value[:original_name]}\", @\"#{key}\"" }
      Generator.properties.each{|key, value| decoders << "	[coder encodeObject:self.#{key} forKey:@\"#{key}\"];" }
      Generator.properties.each{|key, value| encoders << "		self.#{key} = [coder decodeObjectForKey:@\"#{key}\"];" }
      
      source =
        "//\n"+
        "//  Base#{model_name}.m\n"+
        "//\n\n"+

        "#import \"Base#{model_name}.h\n\n"+
        "@implementation Base#{model_name}\n\n"+
        "@synthesize "+synthesize.join(", ")+";\n\n"+
        "+ (RKObjectMapping *)objectMapping\n"+
        "{\n"+
        "	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];\n"+
        "	[mapping mapKeyPathsToAttributes:\n"+
        mapping.join(",\n")+", nil];\n"+
        "}\n\n"+
        
        "- (id)initWithCoder:(NSCoder *)coder\n"+
        "{\n"+
        "	self = [[Base#{model_name} alloc] init];\n"+
        "	if (self) {\n"+
        encoders.join("\n")+"\n"+
        "	}\n"+
        "	return self;\n"+
        "}\n\n"+
        
        "- (void)encodeWithCoder:(NSCoder *)coder\n"+
        "{\n"+
        decoders.join("\n")+"\n"+
        "}\n\n"+
        
        "@end"
      
      if Generator.config[:verbose]
        puts source
      end
      
      File.open("Base#{model_name}.m", 'w') {|f| f.write(source) }
    end
    
  end
  
end