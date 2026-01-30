# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
    module Lexers
      class ObjectScript < RegexLexer
        title 'ObjectScript'
        desc "The ObjectScript language (www.intersystems.com)"
        
        tag 'objectscript'

        filenames '*.cls'
        
        
        @@currentMethodLang = ""
        
        def currentMethodLang
            @@currentMethodLang
        end
        
        def currentMethodLang=setlang
            @@currentMethodLang = setlang
        end

        
        def self.currentMethodLang
            @@currentMethodLang
        end
        
        def self.currentMethodLang=setlang
            @@currentMethodLang = setlang
        end

        keywords = %w(
            BREAK B CATCH CLOSE CONTINUE DO DO WHILE ELSE ELSEIF FOR F 
            GOTO HALT H HANG IF I JOB J KILL K LOCK MERGE M NEW N 
            OPEN O QUIT Q READ R RETURN RET SET S TCOMMIT TC THROW 
            TROLLBACK TRO TRY TSTART TS USE VIEW 
            WHILE WRITE W XECUTE X ZKILL ZNSPACE ZN ZTRAP ZWRITE ZW ZZDUMP ZZWRITE
            #DIM ##class
        )

        special_variables = %w(
            \$DEVICE \$ECODE \$ESTACK \$ETRAP \$HALT \$HOROLOG \$IO \$JOB \$KEY 
            \$NAMESPACE \$PRINCIPAL \$QUIT \$ROLES SQLCODE \$STACK \$STORAGE 
            \$SYSTEM \$TEST \$THIS \$THROWOBJ \$TLEVEL \$USERNAME \$X \$Y \$ZA \$ZB 
            \$ZCHILD \$ZEOF \$ZEOS \$ZERROR \$ZHOROLOG \$ZIO \$ZJOB \$ZMODE \$ZNAME 
            \$ZNSPACE \$ZORDER \$ZPARENT \$ZPI \$ZPOS \$ZREFERENCE \$ZSTORAGE 
            \$ZTIMESTAMP \$ZTIMEZONE \$ZTRAP \$ZVERSION 
        )

=begin
        class_keywords = %w(
            Abstract ClassType ClientDataType ClientName CompileAfter DdlAllowed DependsOn
            Deprecated Final GeneratedBy Hidden Inheritance Language LegacyInstanceContext
            NoExtent OdbcType Owner ProcedureBlock PropertyClass ServerOnly Sharded
            SoapBindingStyle SoapBodyUse SqlCategory SqlRowIdName SqlRowIdPrivate SqlTableName
            StorageStrategy System ViewQuery
        )

        property_keywords = %w(
            Aliases Calculated Cardinality ClientName Collection Deprecated
            Final Identity InitialExpression Internal Inverse MultiDimensional
            OnDelete Private ReadOnly Required ServerOnly SqlColumnNumber
            SqlComputeCode SqlComputed SqlComputeOnChange SqlFieldName SqlListDelimiter
            SqlListType Transient
        )

        method_keywords = %w(
            Abstract ClientName CodeMode Deprecated ExternalProcName Final ForceGenerate
            GenerateAfter Internal Language NotInheritable PlaceAfter Private ProcedureBlock
            PublicList Requires ReturnResultSets ServerOnly SoapAction SoapBindingStyle 
            SoapBodyUse SoapMessageName SoapNameSpace SoapRequestMessage SoapTypeNameSpace
            SqlName SqlProc WebMethod
        )

        foreignKey_keywords = %w(
            Internal NoCheck OnDelete OnUpdate SqlName
        )

        index_keywords = %w(
            Abstract Condition CoshardWith Data Extent IdKey Internal PrimaryKey
            ShardKey SqlName Type Unique
        )
        
        xdata_keywords = %w(
            Internal MimeType SchemaSpec XMLNamespace
        )

        class_def = %w(
            ForeignKey Index ClassMethod Method Parameter Projection Property Query Trigger XData Storage
        )
=end

        operators = /[~^*\_\-!'%&\[\]\#(){}<>\|+=:;,.\/?-@]/
        
        function = /\${1,3}[a-z][a-z0-9]*\b/i   #function, macro, label call

        # used for class name, routine name...
        id = /%?([a-z][a-z\d]*\.)*[a-z][a-z\d]*/i
        s_name = /[a-z]+([0-9]|[a-z])*/i
        
        label = /^[a-z]+([0-9]|[a-z])*/i
        
        string = /"(\\\\|\\"|[^"])*"/
        numeric = /[0-9\.]+[0-9]|[0-9\.]/
        whitespace = /[\s\r\n\t]*/
        double_quoted_string = /"[^"]*"/

        embedded_sql = /\&sql\b/i
        embedded_js = /\&js\b/i
        embedded_html = /\&html\b/i
        

        ### RegEx ###
        # Capture all content until a line start with "}"
        # It will useful to capture method implementation and
        # delegate to another lexer if it's not an Objectscript implementation
        # capture_method_implementation = /^(?!})(^(?!})(.*)\s)*/
        capture_method_implementation = /(^(?!})(.*)\s)*/

        # Capture the "} that means the end of method implementation
        end_of_method_implementation = /^}$/

        # Capture "{" that means the start of method implementation
        start_method_implementation = /^\{$/

        # Capture everything between { ... }
        capture_json = /\{(?:("[^"]+"|[^}{])+|(\g<0>))*+\}/

        # Capture type declaration "As" "As Array Of" "As List Of"
        capture_type_of = /\s+(As Array Of|As List Of|As)\s+/i
        
        # single line comment ex: // comment line
        comment_single_line = /\/\/.*?$/
        
        # class documentation comment
        comment_documentation = /\/\/\/.*?$/

        state :root do
            ObjectScript.currentMethodLang = ""
            rule %r/[^\S\n]+/, Text
            rule comment_single_line, Comment::Single
            rule comment_documentation, Comment::Doc
            rule %r(\;.*?$), Comment::Single
            rule %r(/\*.*?\*/)m, Comment::Multiline

            rule double_quoted_string, Str
            
            
            rule %r(^Include|Import), Keyword::Namespace
            
            rule %r/^(Parameter)(\s)((?:[a-z][0-9a-z]*)|(?:"[^"]+"))/i do |m|
                token Keyword, m[1]                     # Parameter Keyword
                token Text, m[2]                        # White space
                token Name, m[3]                        # Parameter Name
                push :cls_parameter_definition
            end

            rule %r/^(Class)(\s)(%?([a-z][a-z\d]*\.)*[a-z][a-z\d]*)/i do |m|
                token Keyword::Declaration, m[1]        # class Keyword
                token Text, m[2]                        # White space
                token Name::Class, m[3]                 # The class name
                push :cls_definition
            end 
            
            rule %r/^(Projection|Property|Method|ClassMethod|ClientMethod|Query|XData)(\s)((?:[a-z][0-9a-z]*)|(?:"[^"]+"))/i do |m|
                token Keyword::Declaration, m[1]        # Property Keyword
                token Text, m[2]                        # White space

                ObjectScript.currentMethodLang = m[1] == "Query" ? "sql" : ""  # If Query declaration we must to delegate to SQL Lexer later
                
                case m[1]
                when "Projection", "Property"
                    token Name::Property, m[3]          # The name of the property \ projection
                    push :cls_property_definition
                when "Method", "ClassMethod", "ClientMethod", "Query"
                    token Name::Function, m[3]          # The name of the method
                    push :cls_method_definition
                when "XData"
                    token Name, m[3]                    # The name of the xData
                    push :cls_xdata_definition
                else
                    token Text, m[3] if m[3] != nil     # err
                end
            end

            rule %r/^(Index\s+)([a-z0-9]+)(\s+On\s+)/i do |m|
                token Keyword::Declaration, m[1]
                token Name::Property, m[2]
                token Keyword, m[3]
                push :cls_index_definition
            end
            
            rule %r/^(Storage)(\s+)((?:[a-z][0-9a-z]*)|(?:"[^"]+"))/i do |m|
                token Keyword::Declaration, m[1]    # Storage
                token Text, m[2]                    # Space
                token Name, m[3]                    # Storage Name
                push :cls_storage_definition
            end

            rule %r/^(ForeignKey)(\s+)([a-z0-9]+)/i do |m|
                token Keyword::Declaration, m[1]
                token Text, m[2]
                token Name::Property, m[3]
                push :cls_foreignkey_definition
            end

            rule embedded_sql, Name::Entity, :embedded_sql_start
            rule embedded_js, Name::Entity, :embedded_js_start
            rule embedded_html, Name::Entity, :embedded_html_start

            #rule %r/^#{class_def.join('|')}/i, Keyword::Declaration, :cdef_common
            
            rule label, Name::Label
            rule %r/(?:#{special_variables.join('|')})\b/i, Name::Builtin
            rule %r/(?:#{keywords.join('|')})\b/i, Keyword
            rule function, Name::Function
            rule operators, Operator

            rule %r/[a-z0-9]+/i, Literal
            rule numeric, Literal::Number
        end
        
        state :cls_property_definition do
            rule %r(\;), Punctuation
            rule %r($), Text, :pop!
            rule capture_type_of, Keyword, :n_classname
            rule %r(\s+), Text
            rule %r(\(), Operator, :generic_parameters_started
            rule %r(\[), Operator, :generic_keywords_started
        end

        state :cls_xdata_definition do
            rule start_method_implementation do |m|
                token Text, m[0]

                case ObjectScript.currentMethodLang
                when "json"
                    push :delegate_json
                when "javascript"
                    push :delegate_javascript
                else
                    push :delegate_xml
                end
            
            end

            rule %r(\s+), Text
            rule %r(\[), Operator, :generic_keywords_started
            
            rule end_of_method_implementation, Text, :pop!
        end

        state :cls_parameter_definition do
            mixin :common_block_code
            rule %r(\;), Punctuation
            rule %r($), Text, :pop!
            rule %r(\s+), Text
            rule %r(\[), Operator, :generic_keywords_started
            
        end

        state :cls_method_definition do
            rule %r(\(), Operator, :generic_parameters_started
            
            rule %r(\n^\{$) do |m|
                token Text, m[0]
                
                case ObjectScript.currentMethodLang
                when "python"
                    push :delegate_python
                when "javascript"
                    push :delegate_javascript
                when "sql"
                    push :delegate_sql
                else
                    pop!
                end
  
            end

            rule end_of_method_implementation, Text, :pop!
            rule %r($), Text, :pop!
            rule %r(\s+(As Array Of|As List Of|As)\s+), Keyword, :n_classname
            rule %r(\s), Text
            rule double_quoted_string, Literal::String
            rule %r(\[), Operator, :generic_keywords_started
            
        end

        state :cls_index_definition do
            rule %r([,;]), Punctuation
            rule s_name, Name::Property
            rule %r(\[), Operator, :generic_keywords_started
            rule %r(\(), Operator, :generic_parameters_started
            rule operators, Operator
            rule %r($), Text, :pop!
            rule %r(\s+), Text
        end

        state :cls_foreignkey_definition do
            rule %r(\(), Operator, :generic_parameters_started
            rule %r(\[), Operator, :generic_keywords_started
            rule %r/References/i, Keyword
            rule id, Name::Property
            rule %r($), Text, :pop!
            rule %r(\s), Text
            rule %r([;]), Punctuation
        end

        state :common_block_code do
            rule double_quoted_string, Literal::String
            rule numeric, Literal::Number
            rule function, Name::Function
            rule operators, Operator
            rule capture_type_of, Keyword, :n_classname
            rule %r/(?:#{keywords.join('|')})\b/i, Keyword
        end 

        state :generic_parameters_started do
            rule %r/([a-z0-9]+)(\s+)((As?\s+)(%?([a-z][a-z0-9\d]*\.)*[a-z][a-z0-9\d]*))?((\s*[=])(\s+)(([0-9\.]+[0-9]|[0-9\.])|("[^"]*")|(\{(?:("[^"]+"|[^}{])+|(\g<13>))*+\})|(\w+\/[-+.\w]+)|([a-z]*)))?/i do |m|
                #token (in_state? :cls_method_definition) ? Name : Name::Constant, m[1]
                token Name, m[1]
                token Text, m[2] if m[2] != nil
                token Keyword, m[4] if m[4] != nil
                token Name::Class, m[5] if m[5] != nil
                token Operator, m[8] if m[8] != nil
                token Text, m[9] if m[9] != nil
                delegate ObjectScript, m[10] if m[10] != nil
            end
            
            rule %r(,), Punctuation
            rule %r(\)), Operator, :pop!
            rule %r(\s+), Text
            rule s_name, Name
        end

        state :generic_keywords_started do

            rule %r/([a-z]+)(\s+)([=])(\s+)((\([^)]*\))|([0-9\.]+[0-9]|[0-9\.])|("[^"]*")|({.*})|(\w+\/[-+.\w]+)|([a-z]*))/i do |m|
                token Keyword, m[1]
                token Text, m[2]
                token Operator, m[3]
                token Text, m[4]
                
                keywordName = m[1].downcase
                keywordValue = m[5].downcase
                
                if keywordName =~ /^(language|mimetype)$/ then
                    token Text, m[5]
                    case keywordValue
                    when "application/json"
                        ObjectScript.currentMethodLang = "json"
                    when "application/xml"
                        ObjectScript.currentMethodLang = "xml"
                    else
                        ObjectScript.currentMethodLang = keywordValue
                    end
                elsif m[5].chars.first == "{" then
                    puts "delegate ObjectScript\n5."+m[5] if @debug
                    delegate ObjectScript, m[5]
                else
                    token Literal::String, m[5]
                end

            end

            rule %r/[a-z]+/i, Keyword
            rule %r/[,]/, Punctuation
            rule %r(\]), Operator, :pop!
            rule %r(\s+), Text
        end

        state :n_classname do
            rule %r(\s+), Text
            rule id, Name::Class, :pop!
        end

        state :cdef_common do
            rule capture_type_of, Keyword, :n_classname
            rule %r($), Text, :pop!
            rule %r/\s+/m, Text
            rule %r/(?:#{class_keywords.join('|')})\b/, Keyword::Declaration
            rule operators, Operator
            rule function, Name::Function
            rule numeric, Literal::Number
            rule string, Str
            rule s_name, Name
        end
        
        
        state :cls_definition do
            rule %r([()]), Operator
            
            rule %r($), Text, :pop!
            rule %r(,), Punctuation
            rule %r(\s+), Text
            rule id, Name::Class
            rule %r(Extends), Keyword
            rule %r(\[), Operator, :generic_keywords_started
            
        end

        state :cls_storage_definition do
            rule %r/\s+/, Text
            rule start_method_implementation do |m|
                token Text, m[0]
                push :delegate_xml
            end
            rule end_of_method_implementation, Text, :pop!
        end

        state :delegate_sql do
            rule %r/^}$/, Text, :pop!
            rule capture_method_implementation do |m|
                puts "+BEGIN delegate to SQL\n" + m[0] if @debug
                delegate ObjectScriptSQL, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end
        end

        # used to delegate XML XData to the XML lexer
        state :delegate_xml do
            rule capture_method_implementation do |m|
                puts "+delegate do XML Lexer \n" + m[0] if @debug
                delegate XML, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end
        end

        state :delegate_python do
            rule capture_method_implementation do |m|
                puts "+BEGIN delegate to Python\n" + m[0] if @debug
                delegate Python, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end 
        end

        state :delegate_json do
            rule capture_json do |m|
                puts "+BEGIN delegate to JSON lexer\n" + m[0] if @debug
                delegate JSON, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end
        end

        state :delegate_javascript do
            rule %r/^(?!})(^(?!})(.*)\s)*/ do |m|
                delegate Javascript, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end
        end

        state :embedded_sql_start do
            rule %r/\((?:('[^']+'|[^\)\(])+|(\g<0>))*+\)/m do |m|
                delegate ObjectScriptSQL, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end
            
            rule(//) { pop! }
        end

        state :embedded_js_start do
            rule %r/\<(?:("[^"]+"|[^\>\<])+|(\g<0>))*+\>/m do |m|
                delegate Javascript, m[0]
                ObjectScript.currentMethodLang = ""
                pop!
            end
        end

        state :embedded_html_start do
            rule %r/\<(?:("[^"]+"|[^\>\<])+|(\g<0>))*+\>/m do |m|
                token Operator, "<"
                delegate HTML, m[0][1..-1]
                ObjectScript.currentMethodLang = ""
                pop!
            end
        end
        
      end

      class ObjectScriptSQL < SQL
        @@operators = "[\$+*/<>=~!@#%&|?^-]"
        def self.operators
            @@operators
        end

        state :root do
            rule %r/\s+/m, Text
            rule %r/--.*/, Comment::Single
            rule %r(/\*), Comment::Multiline, :multiline_comments
            rule %r/\d+/, Num::Integer
            rule %r/'/, Str::Single, :single_string
            # A double-quoted string refers to a database object in our default SQL
            # dialect, which is apropriate for e.g. MS SQL and PostgreSQL.
            rule %r/"/, Name::Variable, :double_string
            rule %r/`/, Name::Variable, :backtick
    
            rule %r/\w[\w\d]*/ do |m|
              if self.class.keywords_type.include? m[0].upcase
                token Name::Builtin
              elsif self.class.keywords.include? m[0].upcase
                token Keyword
              else
                token Name
              end
            end
    
            rule %r(#{ObjectScriptSQL.operators}), Operator
            rule %r/[;:()\[\]\{\},.]/, Punctuation
          end

      end
    end
end