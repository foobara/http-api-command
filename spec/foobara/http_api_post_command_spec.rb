RSpec.describe Foobara::HttpApiPostCommand do
  context "when command issues POST request" do
    let(:command_class) do
      mixin = described_class

      stub_class(:Post, Foobara::Command) do
        include mixin

        inputs do
          foo :string, :required
        end

        result do
          args Hash
          data :string
          files Hash
          form Hash
          headers Hash
          json Hash
          origin :string
          url :string
        end

        url "https://httpbin.org/post"
      end
    end

    let(:command) { command_class.new(inputs) }
    let(:outcome) { command.run }
    let(:result) { outcome.result }
    let(:errors) { outcome.errors }
    let(:errors_hash) { outcome.errors_hash }

    let(:inputs) do
      { foo: "bar" }
    end

    it "is successful", vcr: { record: :none } do
      expect(outcome).to be_success
      expect(result).to be_a(Hash)
    end
  end
end
