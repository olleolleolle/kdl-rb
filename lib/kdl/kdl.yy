class KDL::Parser
  options no_result_var
  token IDENT
        STRING RAWSTRING
        INTEGER FLOAT TRUE FALSE NULL
        WS NEWLINE
        LPAREN RPAREN
        EQUALS
        SEMICOLON
        EOF
rule
  document  : nodes { KDL::Document.new(val[0]) }

  nodes     : none                { [] }
            | linespace_star node { [val[1]] }
            | nodes node          { [*val[0], val[1]] }
  node_decl : identifier            { KDL::Node.new(val[0]) }
            | node_decl WS value    { val[0].tap { |x| x.arguments << val[2] } }
            | node_decl WS property { val[0].tap { |x| x.properties[val[2][0]] = val[2][1] } }
  node      : node_decl node_term               { val[0] }
            | node_decl node_children node_term { val[0].tap { |x| x.children = val[1] } }
  node_children: ws_star LPAREN nodes RPAREN { val[2] }
  node_term: linespaces | semicolon_term
  semicolon_term: SEMICOLON | SEMICOLON linespaces

  identifier: IDENT  { val[0] }
            | STRING { val[0] }

  property: identifier EQUALS value { [val[0], val[2]] }

  value : STRING     { KDL::Value::String.new(val[0]) }
        | RAWSTRING  { KDL::Value::String.new(val[0]) }
        | INTEGER    { KDL::Value::Int.new(val[0]) }
        | FLOAT      { KDL::Value::Float.new(val[0]) }
        | boolean    { KDL::Value::Boolean.new(val[0]) }
        | NULL       { KDL::Value::Null }

  boolean : TRUE  { true }
          | FALSE { false }

  ws_star: none | WS
  linespace: NEWLINE | EOF | WS
  linespaces: linespace | linespaces linespace
  linespace_star: none | linespaces

  none: { nil }

---- inner
  def parse(str)
    @tokenizer = ::KDL::Tokenizer.new(str)
    do_parse
  end

  private

  def next_token
    @tokenizer.next_token
  end
