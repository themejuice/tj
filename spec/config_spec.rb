require_relative "../lib/theme-juice"

describe ThemeJuice::Config do
  it { is_expected.to respond_to :method_missing }
end
