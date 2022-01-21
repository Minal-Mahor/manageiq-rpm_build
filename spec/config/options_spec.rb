RSpec.describe "options.yml" do
  let(:options) { ManageIQ::RPMBuild::OPTIONS }

  nightly_versions = [
    "13.1.0-20211208000053",
    "13.1.0-20211209000053",
  ]

  release_versions = [
    "13.1.0-alpha1",
    "13.1.1-beta1",
    "13.1.2-rc1",
    "13.1.3-rc2",
    "13.1.4-1",
    "13.1.4-1.1",
    "13.1.5-1",
    "13.2.1-1",
  ]

  suffixes = [
    nil, # For manageiq
    "appliance",
    "appliance-tools",
    "core",
    "gemset",
    "pods",
    "system",
    "ui",
  ]

  shared_examples "expect_included_rpm" do |file, rpm|
    it("includes #{file}") { expect(file).to match(options.rpm_repository.content[repo].rpms[rpm]) }
  end

  shared_examples "expect_excluded_rpm" do |file, rpm|
    it("excludes #{file}") { expect(file).not_to match(options.rpm_repository.content[repo].rpms[rpm]) }
  end

  describe "nightly repo" do
    let(:repo) { "13-morphy-nightly" }
    context "manageiq rpms" do
      suffixes.each do |suffix|
        release_versions.each do |version|
          file = ["manageiq", suffix, version].compact.join("-") + ".el8.x86_64.rpm"
          include_examples("expect_excluded_rpm", file, "manageiq-nightly")
        end

        nightly_versions.each do |version|
          file = ["manageiq", suffix, version].compact.join("-") + ".el8.x86_64.rpm"
          include_examples("expect_included_rpm", file, "manageiq-nightly")
        end
      end
    end
  end

  describe "release repo" do
    let(:repo) { "13-morphy" }
    context "manageiq-release rpms" do
      [
        "manageiq-release-13.0-1.el8.noarch.rpm",
        "manageiq-release-13.0-2.el8.noarch.rpm",
      ].each { |file| include_examples("expect_included_rpm", file, "manageiq-release") }
    end

    context "manageiq rpms" do
      suffixes.each do |suffix|
        release_versions.each do |version|
          file = ["manageiq", suffix, version].compact.join("-") + ".el8.x86_64.rpm"
          include_examples("expect_included_rpm", file, "manageiq")
        end

        nightly_versions.each do |version|
          file = ["manageiq", suffix, version].compact.join("-") + ".el8.x86_64.rpm"
          include_examples("expect_excluded_rpm", file, "manageiq")
        end
      end
    end
  end
end