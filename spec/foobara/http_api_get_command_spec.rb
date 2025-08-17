RSpec.describe Foobara::HttpApiCommand do
  describe "#run" do
    context "when command hits rubygems search API" do
      let(:command_class) do
        mixin = described_class

        stub_class(:Search, Foobara::Command) do
          include mixin

          inputs do
            query :string, :required
          end

          result [Hash]

          base_url "https://rubygems.org/api/v1"
          path "/search.json"

          def build_request_body
            self.request_body = { query: }
          end
        end
      end

      let(:command) { command_class.new(inputs) }
      let(:outcome) { command.run }
      let(:result) { outcome.result }
      let(:errors) { outcome.errors }
      let(:errors_hash) { outcome.errors_hash }

      let(:inputs) do
        { query: "foobara" }
      end

      it "is successful", vcr: { record: :none } do
        expect(outcome).to be_success
        expect(result).to be_an(Array)
      end
    end

    context "when command hits rubygems versions API" do
      let(:command_class) do
        mixin = described_class

        stub_class(:GetVersions, Foobara::Command) do
          include mixin

          inputs do
            gem_name :string, :required
          end

          result [Hash]

          url { "https://rubygems.org/api/v1/versions/#{gem_name}.json" }
        end
      end

      let(:command) { command_class.new(inputs) }
      let(:outcome) { command.run }
      let(:result) { outcome.result }
      let(:errors) { outcome.errors }
      let(:errors_hash) { outcome.errors_hash }

      let(:inputs) do
        { gem_name: "foobara" }
      end

      it "is successful", vcr: { record: :none } do
        expect(outcome).to be_success
        expect(result).to be_an(Array)
      end

      context "when only specifying the path with a block" do
        let(:command_class) do
          mixin = described_class

          stub_class(:GetVersions, Foobara::Command) do
            include mixin

            inputs do
              gem_name :string, :required
            end

            result [Hash]

            base_url "https://rubygems.org"
            path { "/api/v1/versions/#{gem_name}.json" }
          end
        end

        it "is successful", vcr: { record: :none } do
          expect(outcome).to be_success
          expect(result).to be_an(Array)
        end
      end
    end
  end
end
