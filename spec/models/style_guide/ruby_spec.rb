require "spec_helper"

describe StyleGuide::Ruby, "#violations_in_file" do
  include ConfigurationHelper

  context "with default configuration" do
    describe "for { and } as %r literal delimiters" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
          "test" =~ %r|test|
        CODE
      end
    end

    describe "for private prefix" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
          private def foo
            bar
          end
        CODE
      end
    end

    describe "for trailing commas" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
          _one = [
            1,
          ]
          _two(
            1,
          )
          _three = {
            one: 1,
          }
        CODE
      end
    end

    describe "for single line conditional" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
if signed_in? then redirect_to dashboard_path end

while signed_in? do something end
        CODE
      end
    end

    describe "for has_* method name" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
def has_something?
  "something"
end
        CODE
      end
    end

    describe "for is_* method name" do
      it "returns violations" do
        violations = ["C:  1:  5: Rename `is_something?` to `something?`."]

        expect(violations_in(<<-CODE)).to eq violations
def is_something?
  "something"
end
        CODE
      end
    end

    describe "when using detect" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
users.detect(&:active?)
        CODE
      end
    end

    describe "when using find" do
      it "returns violations" do
        violations = ["C:  1:  7: Prefer `detect` over `find`."]

        expect(violations_in(<<-CODE)).to match violations
users.find(&:active?)
        CODE
      end
    end

    describe "when using select" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
users.select(&:active?)
        CODE
      end
    end

    describe "when using find_all" do
      it "returns violations" do
        violations = ["C:  1:  7: Prefer `select` over `find_all`."]

        expect(violations_in(<<-CODE)).to eq violations
users.find_all(&:active?)
        CODE
      end
    end

    describe "when using map" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
users.map(&:active?)
        CODE
      end
    end

    describe "when using collect" do
      it "returns violations" do
        violations = ["C:  1:  7: Prefer `map` over `collect`."]

        expect(violations_in(<<-CODE)).to eq violations
users.collect(&:active?)
        CODE
      end
    end

    describe "when using inject" do
      it "returns no violations" do
        expect(violations_in(<<-CODE)).to eq []
          users.inject(0) do |sum, user|
            sum + user.age
          end
        CODE
      end
    end

    describe "when using reduce" do
      it "returns violations" do
        violations = ["C:  1:  7: Prefer `inject` over `reduce`."]

        expect(violations_in(<<-CODE)).to eq violations
users.reduce(0) do |_, user|
  user.age
end
        CODE
      end
    end

    context "for long line" do
      it "returns violation" do
        violations = ["C:  1: 81: Line is too long. [81/80]"]

        expect(violations_in("a" * 81 + "\n")).to eq violations
      end
    end

    context "for trailing whitespace" do
      it "returns violation" do
        violations = ["C:  1: 11: Trailing whitespace detected."]

        expect(violations_in("[1, 2].sum \n")).to eq violations
      end
    end

    context "for spaces after (" do
      it "returns violations" do
        violations = ["C:  1:  8: Space inside parentheses detected."]

        expect(violations_in(<<-CODE)).to eq violations
logger( "test")
        CODE
      end
    end

    context "for spaces before )" do
      it "returns violations" do
        violations = ["C:  1: 14: Space inside parentheses detected."]

        expect(violations_in(<<-CODE)).to eq violations
logger("test" )
        CODE
      end
    end

    context "for spaces before ]" do
      it "returns violations" do
        violations = ["C:  1:  9: Space inside square brackets detected."]

        expect(violations_in(<<-CODE)).to eq violations
a["test" ]
        CODE
      end
    end

    context "for private methods indented more than public methods" do
      it "returns violations" do
        violations = ["C:  7:  3: Inconsistent indentation detected."]

        expect(violations_in(<<-CODE)).to eq violations
def one
  1
end

private

  def two
    2
  end
        CODE
      end
    end

    context "for leading dot used for multi-line method chain" do
      it "returns violations" do
        violations = ["C:  2:  3: Place the . on the previous line, together with the "\
                      "method call receiver."]

        expect(violations_in(<<-CODE)).to eq violations
one
  .two
        CODE
      end
    end

    context "for tab indentation" do
      it "returns violations" do
        violations = ["C:  2:  1: Use 2 (not 1) spaces for indentation.", "C:  2:  1: Tab detected."]

        expect(violations_in(<<-CODE)).to eq violations
def test
\tlogger "test"
end
        CODE
      end
    end

    context "for two methods without newline separation" do
      it "returns violations" do
        violations = ["C:  4:  1: Use empty lines between defs."]

        expect(violations_in(<<-CODE)).to eq violations
def one
  1
end
def two
  2
end
        CODE
      end
    end

    context "for operator without surrounding spaces" do
      it "returns violations" do
        violations = ["C:  1:  2: Surrounding space missing for operator '+'."]
        expect(violations_in(<<-CODE)).to eq violations
1+1
        CODE
      end
    end

    context "for comma without trailing space" do
      it "returns violations" do
        violations = ["C:  1: 12: Space missing after comma."]

        expect(violations_in(<<-CODE)).to eq violations
logger :one,:two
        CODE
      end
    end

    context "for colon without trailing space" do
      it "returns violations" do
        violations = ["C:  1:  5: Space missing after colon.",
                      "C:  1:  1: Space inside { missing.",
                      "C:  1:  7: Space inside } missing."]

        expect(violations_in(<<-CODE)).to eq violations
{one:1}
        CODE
      end
    end

    context "for semicolon without trailing space" do
      it "returns violations" do
        violations = ["C:  1: 12: Do not use semicolons to terminate expressions.",
                      "C:  1: 12: Space missing after semicolon."]

        expect(violations_in(<<-CODE)).to eq violations
logger :one;logger :two
        CODE
      end
    end

    context "for opening brace without leading space" do
      it "returns violations" do
        violations = ["C:  1:  3: Surrounding space missing for operator '='."]

        expect(violations_in(<<-CODE)).to eq violations
a ={ one: 1 }
a
        CODE
      end
    end

    context "for opening brace without trailing space" do
      it "returns violations" do
        violations = ["C:  1:  5: Space inside { missing."]

        expect(violations_in(<<-CODE)).to eq violations
a = {one: 1 }
a
        CODE
      end
    end

    context "for closing brace without leading space" do
      it "returns violations" do
        violations = ["C:  1: 13: Space inside } missing."]

        expect(violations_in(<<-CODE)).to eq violations
a = { one: 1}
a
        CODE
      end
    end

    context "for method definitions with optional named arguments" do
      it "does not return violations" do
        expect(violations_in(<<-CODE)).to be_empty
def register_email(email:)
  register(email)
end
        CODE
      end
    end

    context "for argument list spanning multiple lines" do
      context "when each argument is not on its own line" do
        it "returns violations" do
          code = <<-CODE.strip_heredoc
            validates :name,
              presence: true,
              uniqueness: true
          CODE

          expect(violations_in(code)).to eq [
            "C:  2:  3: Align the parameters of a method call if they span more than " +
              "one line."
          ]
        end
      end

      context "when each argument is on its own line" do
        it "returns no violations" do
          code = <<-CODE.strip_heredoc
            validates(
              :name,
              presence: true,
              uniqueness: true
            )
          CODE

          expect(violations_in(code)).to be_empty
        end
      end
    end

    context "for required keyword arguments" do
      context "without space after arguments" do
        it "returns no violations" do
          code = <<-CODE.strip_heredoc
            def initialize(name:, age:)
              @name = name
              @age = age
            end
          CODE

          expect(violations_in(code)).to be_empty
        end
      end

      context "with spaces after arguments" do
        it "returns violations" do
          code = <<-CODE.strip_heredoc
            def initialize(name: , age: )
              @name = name
              @age = age
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq [
            "C:  1: 21: Space found before comma.",
            "C:  1: 28: Space inside parentheses detected.",
          ]
        end
      end
    end
  end

  context "with custom configuration" do
    it "finds only one violation" do
      config = {
        "StringLiterals" => {
          "EnforcedStyle" => "double_quotes"
        }
      }

      violations = violations_with_config(config)

      expect(violations).to eq ["C:  2:  5: Use the new Ruby 1.9 hash syntax."]
    end

    it "can use custom configuration to display rubocop cop names" do
      config = { "AllCops" => { "DisplayCopNames" => "true" } }

      violations = violations_with_config(config)

      expect(violations).to eq [
        "C:  2:  5: Style/HashSyntax: Use the new Ruby 1.9 hash syntax."
      ]
    end

    context "with old-style syntax" do
      it "has one violation" do
        config = {
          "StringLiterals" => {
            "EnforcedStyle" => "single_quotes"
          },
          "HashSyntax" => {
            "EnforcedStyle" => "hash_rockets"
          },
        }

        violations = violations_with_config(config)

        expect(violations).to eq [
          "C:  2: 13: Prefer single-quoted strings when you don't need string "\
          "interpolation or special symbols."
        ]
      end
    end

    context "with excluded files" do
      it "has no violations" do
        config = {
          "AllCops" => {
            "Exclude" => ["lib/a.rb"]
          }
        }

        violations = violations_with_config(config)

        expect(violations).to be_empty
      end

      it 'allows a cop to be excluded for specific files or directories' do
        config = {
          "StringLiterals" => {
            "EnforcedStyle" => "single_quotes"
          },
          "HashSyntax" => {
            "Exclude" => ["lib/**/*"]
          }
        }

        violations = violations_with_config(config)

        expect(violations).to eq [
          "C:  2: 13: Prefer single-quoted strings when you don't need string "\
          "interpolation or special symbols."
        ]
      end
    end

    context "with using block" do
      it "returns violations" do
        violations = ["C:  1:  1: Pass `&:name` as an argument to `map` "\
                      "instead of a block."]

        expect(violations_in(<<-CODE)).to eq violations
users.map do |user|
  user.name
end
        CODE
      end
    end

    context "with calls debugger" do
      it "returns violations" do
        violations = ["W:  1:  1: Remove debugger entry point `binding.pry`."]

        expect(violations_in(<<-CODE)).to eq violations
binding.pry
        CODE
      end
    end

    context "with empty lines around block" do
      it "returns violations" do
        violations = ["C:  2:  1: Extra empty line detected at block body beginning.",
                      "C:  4:  1: Extra empty line detected at block body end."]

        expect(violations_in(<<-CODE)).to eq violations
block do |hoge|

  hoge

end
        CODE
      end
    end

    context "with unnecessary space" do
      it "returns violations" do
        violations = ["C:  1:  5: Unnecessary spacing detected."]

        expect(violations_in(<<-CODE)).to eq violations
hoge  = "https://github.com/bbatsov/rubocop"
hoge
        CODE
      end
    end

    def violations_with_config(config)
      content = <<-TEXT.strip_heredoc
        def test_method
          { :foo => "hello world" }
        end
      TEXT

      violations_in(content, config: config)
    end
  end

  context "default configuration" do
    it "uses a default configuration for rubocop" do
      spy_on_rubocop_team
      spy_on_rubocop_configuration_loader
      config_file = default_configuration_file(StyleGuide::Ruby)
      code = <<-CODE
        private def foo
          bar
        end
      CODE

      violations_in(code, repository_owner_name: "not_thoughtbot")

      expect(RuboCop::ConfigLoader).to have_received(:configuration_from_file).
        with(config_file)

      expect(RuboCop::Cop::Team).to have_received(:new).
        with(anything, default_configuration, anything)
    end
  end

  context "thoughtbot organization PR" do
    it "uses the thoughtbot configuration for rubocop" do
      spy_on_rubocop_team
      spy_on_rubocop_configuration_loader
      config_file = thoughtbot_configuration_file(StyleGuide::Ruby)
      code = <<-CODE
        private def foo
          bar
        end
      CODE

      thoughtbot_violations_in(code)

      expect(RuboCop::ConfigLoader).to have_received(:configuration_from_file).
        with(config_file)

      expect(RuboCop::Cop::Team).to have_received(:new).
        with(anything, thoughtbot_configuration, anything)
    end

    describe "when using reduce" do
      it "returns no violations" do
        expect(thoughtbot_violations_in(<<-CODE)).to eq []
          users.reduce(0) do |sum, user|
            sum + user.age
          end
        CODE
      end
    end

    describe "when using inject" do
      it "returns violations" do
        violations = ["C:  1: 17: Prefer `reduce` over `inject`."]

        expect(thoughtbot_violations_in(<<-CODE)).to eq violations
          users.inject(0) do |_, user|
            user.age
          end
        CODE
      end
    end

    def thoughtbot_violations_in(content)
      violations_in(content, repository_owner_name: "thoughtbot")
    end
  end

  private

  def violations_in(content, config: nil, repository_owner_name: "ralph")
    repo_config = double("RepoConfig", enabled_for?: true, for: config)
    style_guide = StyleGuide::Ruby.new(repo_config, repository_owner_name)
    style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
  end

  def build_file(content)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    filename = Rails.root.join("lib/a.rb")
    double("CommitFile", content: content, line_at: line, filename: filename)
  end

  def default_configuration
    config_file = default_configuration_file(StyleGuide::Ruby)
    RuboCop::ConfigLoader.configuration_from_file(config_file)
  end

  def thoughtbot_configuration
    config_file = thoughtbot_configuration_file(StyleGuide::Ruby)
    RuboCop::ConfigLoader.configuration_from_file(config_file)
  end

  def spy_on_rubocop_team
    allow(RuboCop::Cop::Team).to receive(:new).and_call_original
  end

  def spy_on_rubocop_configuration_loader
    allow(RuboCop::ConfigLoader).to receive(:configuration_from_file).
      and_call_original
  end
end
