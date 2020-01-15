require_relative "./lib/sexpir/version"

Gem::Specification.new do |s|
  s.name        = 'sexpir'
  s.version     = Sexpir::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "interchange format for RTL designs"
  s.description = "sexpir is a sexp-based interchange format for RTL design"
  s.authors     = ["Jean-Christophe Le Lann"]
  s.email       = 'lelannje@ensta-bretagne.fr'
  s.files       = [
                    "lib/sexpir/ast.rb",
                    "lib/sexpir/ast_sexp.rb",
                    "lib/sexpir/checker.rb",
                    "lib/sexpir/code_generator.rb",
                    "lib/sexpir/code.rb",
                    "lib/sexpir/compiler.rb",
                    "lib/sexpir/graph.rb",
                    "lib/sexpir/log.rb",
                    "lib/sexpir/parser.rb",
                    "lib/sexpir/printer.rb",
                    "lib/sexpir/ruby_rtl_generator.rb",
                    "lib/sexpir/runner.rb",
                    "lib/sexpir/transformer.rb",
                    "lib/sexpir/version.rb",
                    "lib/sexpir/visitor.rb",
                    "lib/sexpir.rb",
                ]

  s.executables << 'sexpir'
  s.homepage    = 'https://github.com/JC-LL/sexpir'
  s.license     = 'MIT'
  s.post_install_message = "Thanks for installing ! Homepage :https://github.com/JC-LL/sexpir"
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'distribution', '0.7.3'
  s.add_runtime_dependency 'colorize', '0.8.1'

end
