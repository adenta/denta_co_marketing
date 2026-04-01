require "test_helper"

module Content
  class MetadataSchemaTest < ActiveSupport::TestCase
    test "validates and coerces metadata" do
      schema = MetadataSchema.new(
        required: {
          "title" => :string,
          "published_on" => :date
        },
        optional: {
          "draft" => :boolean,
          "tags" => :string_array
        }
      )

      metadata = schema.validate!(
        {
          title: "Example",
          published_on: "2026-04-01",
          draft: false,
          tags: %w[ops product]
        },
        path: Pathname("example.md")
      )

      assert_equal "Example", metadata["title"]
      assert_equal Date.new(2026, 4, 1), metadata["published_on"]
      assert_equal false, metadata["draft"]
      assert_equal %w[ops product], metadata["tags"]
    end

    test "rejects unknown keys" do
      schema = MetadataSchema.new(required: { "title" => :string })

      error = assert_raises(MetadataSchema::ValidationError) do
        schema.validate!({ title: "Example", unknown: "value" }, path: Pathname("example.md"))
      end

      assert_includes error.message, "Unknown front matter keys"
    end

    test "rejects invalid dates" do
      schema = MetadataSchema.new(required: { "published_on" => :date })

      error = assert_raises(MetadataSchema::ValidationError) do
        schema.validate!({ published_on: "04/01/2026" }, path: Pathname("example.md"))
      end

      assert_includes error.message, "must be an ISO 8601 date"
    end
  end
end
