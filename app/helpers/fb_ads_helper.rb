module FbAdsHelper
  def countries_list
    # Should probably use something like: https://rubygems.org/gems/iso_3166
    countries = [
      ["Australia",     "AU"], ["Austria",     "AT"], ["Belgium",        "BE"],
      ["Brazil",        "BR"], ["Canada",      "CA"], ["Croatia",        "HR"],
      ["Denmark",       "DK"], ["Estonia",     "EE"], ["Finland",        "FI"],
      ["France",        "FR"], ["Germany",     "DE"], ["Gibraltar",      "GI"],
      ["Great Britian", "GB"], ["Greece",      "GR"], ["Hong Kong",      "HK"],
      ["Hungary",       "HU"], ["Ireland",     "IE"], ["Israel",         "IL"],
      ["Italy",         "IT"], ["Japan",       "JP"], ["Latvia",         "LV"],
      ["Lithuania",     "LT"], ["Luxembourg",  "LU"], ["Malaysia",       "MY"],
      ["Malta",         "MT"], ["Mexico",      "MX"], ["Netherlands",    "NL"],
      ["New Zealand",   "NZ"], ["Norway",      "NO"], ["Poland",         "PL"],
      ["Portugal",      "PT"], ["Russia",      "RU"], ["Saudi Arabia",   "SA"],
      ["Singapore",     "SG"], ["Spain",       "ES"], ["South Korea",    "KR"],
      ["Sweden",        "SE"], ["Switzerland", "CH"], ["Thailand",       "TH"],
      ["Turkey",        "TR"], ["Ukraine",     "UA"], ["United Kingdom", "GB"],
      ["United States", "US"], ["Vietnam",     "VN"]
    ]

    return countries
  end
end
