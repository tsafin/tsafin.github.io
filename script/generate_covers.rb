#!/usr/bin/env ruby
require "yaml"
require "cgi"
require "digest"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
OUTPUT = File.join(ROOT, "images", "covers")
FORCE = ARGV.include?("--force")
FileUtils.mkdir_p(OUTPUT)

THEMES = {
  "mapreduce" => {
    background: "#dfe5d8", ink: "#23372b", accent: "#557047", soft: "#a7b69a",
    label: "MAPREDUCE / SYSTEMS", mark: "MR", style: "network"
  },
  "meetup" => {
    background: "#e9dcd5", ink: "#3a2925", accent: "#a25945", soft: "#c89c8d",
    label: "MEETUP / COMMUNITY", mark: "SPB", style: "orbit"
  },
  "package" => {
    background: "#ece2ce", ink: "#3b3124", accent: "#9b6a2f", soft: "#cbb486",
    label: "INTERSYSTEMS / TOOLS", mark: "PKG", style: "blocks"
  },
  "personal" => {
    background: "#e9ddd3", ink: "#302824", accent: "#ad593c", soft: "#cfa48f",
    label: "PERSONAL / NOTES", mark: "01", style: "grid"
  }
}.freeze

def theme_for(data)
  text = [data["title"], data["categories"], data["tags"]].flatten.compact.join(" ").downcase
  return THEMES["mapreduce"] if text.match?(/mapreduce|dynamic dispatch|remote proxy/)
  return THEMES["meetup"] if text.match?(/meetup|митап/)
  return THEMES["package"] if text.match?(/package manager|intersystems|caché|cache/)
  THEMES["personal"]
end

def wrap_text(text, width)
  words = text.to_s.gsub(/\s+/, " ").strip.split(" ")
  lines = [""]
  words.each do |word|
    candidate = lines.last.empty? ? word : "#{lines.last} #{word}"
    if candidate.length > width && !lines.last.empty?
      lines << word
    else
      lines[-1] = candidate
    end
  end
  lines
end

def artwork(style, theme)
  ink = theme[:ink]
  accent = theme[:accent]
  soft = theme[:soft]
  mark = CGI.escapeHTML(theme[:mark])
  case style
  when "network"
    <<~SVG
      <g fill="none" stroke="#{accent}" stroke-width="3" opacity="0.65">
        <path d="M790 210 L982 156 L1080 292 L1010 466 L824 432 L748 320 Z"/>
        <path d="M790 210 L824 432 M982 156 L1010 466 M748 320 L1080 292"/>
      </g>
      <g fill="#{theme[:background]}" stroke="#{accent}" stroke-width="4">
        <circle cx="790" cy="210" r="18"/><circle cx="982" cy="156" r="18"/>
        <circle cx="1080" cy="292" r="18"/><circle cx="1010" cy="466" r="18"/>
        <circle cx="824" cy="432" r="18"/><circle cx="748" cy="320" r="18"/>
      </g>
      <circle cx="916" cy="315" r="52" fill="#{accent}" opacity="0.14"/>
      <text x="916" y="331" text-anchor="middle" fill="#{ink}" font-size="42" font-weight="700">#{mark}</text>
    SVG
  when "orbit"
    <<~SVG
      <g fill="none" stroke="#{accent}" opacity="0.48">
        <circle cx="932" cy="328" r="190" stroke-width="2"/>
        <circle cx="932" cy="328" r="128" stroke-width="3" stroke-dasharray="8 12"/>
        <circle cx="932" cy="328" r="64" stroke-width="2"/>
        <path d="M742 328 H1122 M932 138 V518" stroke-width="1"/>
      </g>
      <circle cx="1068" cy="206" r="24" fill="#{accent}"/>
      <circle cx="804" cy="438" r="13" fill="#{soft}"/>
      <text x="932" y="344" text-anchor="middle" fill="#{ink}" font-size="48" font-weight="700">#{mark}</text>
    SVG
  when "blocks"
    <<~SVG
      <g transform="translate(760 152) rotate(-4 170 180)">
        <rect x="38" y="0" width="280" height="112" rx="14" fill="#{soft}" opacity="0.65"/>
        <rect x="0" y="132" width="320" height="126" rx="14" fill="none" stroke="#{accent}" stroke-width="3"/>
        <rect x="44" y="280" width="280" height="126" rx="14" fill="#{accent}" opacity="0.16" stroke="#{accent}" stroke-width="2"/>
        <g fill="#{ink}" font-family="monospace" font-size="26" font-weight="700">
          <text x="72" y="68">PACKAGE</text><text x="40" y="204">INSTALL</text><text x="82" y="354">SHIP →</text>
        </g>
      </g>
    SVG
  else
    <<~SVG
      <g transform="translate(790 144)">
        <rect x="0" y="0" width="300" height="330" rx="22" fill="none" stroke="#{accent}" stroke-width="3" opacity="0.55"/>
        <rect x="28" y="28" width="300" height="330" rx="22" fill="#{soft}" opacity="0.32"/>
        <path d="M50 92 H250 M50 132 H250 M50 172 H180" stroke="#{ink}" stroke-width="3" opacity="0.32"/>
        <text x="50" y="292" fill="#{accent}" font-size="104" font-weight="800" letter-spacing="-8">#{mark}</text>
      </g>
    SVG
  end
end

def cover_svg(data, theme)
  title = data["cover_title"] || data["title"]
  lines = wrap_text(title, 23)
  size = case lines.length
         when 1 then 72
         when 2 then 64
         when 3 then 56
         when 4 then 49
         else 43
         end
  leading = (size * 1.18).round
  first_y = 566 - ((lines.length - 1) * leading)
  text = lines.each_with_index.map do |line, index|
    %(<text x="72" y="#{first_y + index * leading}" font-size="#{size}" font-weight="750" letter-spacing="-1.8">#{CGI.escapeHTML(line)}</text>)
  end.join("\n    ")
  year = data["date"].to_s[0, 4]
  <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="1200" height="750" viewBox="0 0 1200 750">
      <defs>
        <pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse">
          <circle cx="2" cy="2" r="1.3" fill="#{theme[:ink]}" opacity="0.12"/>
        </pattern>
      </defs>
      <rect width="1200" height="750" fill="#{theme[:background]}"/>
      <rect width="1200" height="750" fill="url(#grid)"/>
      <path d="M72 104 H1128" stroke="#{theme[:ink]}" stroke-width="1" opacity="0.22"/>
      <g font-family="'DejaVu Sans', Arial, sans-serif" fill="#{theme[:ink]}">
        <text x="72" y="72" font-size="17" font-weight="700" letter-spacing="3">TIMUR SAFIN / NOTES</text>
        <text x="1128" y="72" text-anchor="end" font-size="15" font-weight="700" letter-spacing="2" fill="#{theme[:accent]}">#{theme[:label]}</text>
        #{text}
        <text x="72" y="690" font-size="16" font-weight="700" letter-spacing="2">TSAFIN.NET</text>
        <text x="1128" y="690" text-anchor="end" font-size="16" font-weight="700" letter-spacing="2">#{year}</text>
      </g>
      #{artwork(theme[:style], theme)}
      <rect x="0" y="0" width="12" height="750" fill="#{theme[:accent]}"/>
    </svg>
  SVG
end

Dir[File.join(ROOT, "_posts", "*")].sort.each do |path|
  content = File.read(path)
  match = content.match(/\A---\r?\n(.*?)\r?\n---\r?\n/m)
  next unless match
  data = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(match[1]) : YAML.load(match[1])
  next unless data.is_a?(Hash) && data["title"]
  thumbnail = data["thumbnail"].to_s
  generated = thumbnail.start_with?("images/covers/")
  has_cover = (data["image"].is_a?(Hash) && data["image"]["teaser"]) || !thumbnail.empty?
  next if has_cover && !(FORCE && generated)

  slug = File.basename(path).sub(/^\d{4}-\d{2}-\d{2}-/, "").sub(/\.[^.]+\z/, "")
  svg_path = File.join(OUTPUT, "#{slug}.svg")
  webp_path = File.join(OUTPUT, "#{slug}.webp")
  social_path = File.join(OUTPUT, "#{slug}-social.png")
  theme = theme_for(data)
  File.write(svg_path, cover_svg(data, theme))

  master_path = File.join(OUTPUT, "#{slug}-master.png")
  success = system("rsvg-convert", "-w", "1200", "-h", "750", svg_path, "-o", master_path)
  success &&= system("convert", master_path, "-quality", "88", webp_path)
  success &&= system("convert", master_path, "-resize", "1008x630", "-background", theme[:background], "-gravity", "center", "-extent", "1200x630", social_path)
  FileUtils.rm_f(master_path)
  abort "Cover rendering failed for #{path}" unless success

  unless has_cover
    newline = content.include?("\r\n") ? "\r\n" : "\n"
    metadata = "thumbnail: images/covers/#{slug}.webp#{newline}social_image: images/covers/#{slug}-social.png#{newline}"
    updated_front = match[0].sub(/\r?\n---\r?\n\z/, "#{newline}#{metadata}---#{newline}")
    content = updated_front + content[match[0].length..-1]
    File.write(path, content)
  end
  puts "Generated images/covers/#{slug}.webp"
end
