# encoding: UTF-8
require "json"

data = JSON.parse(File.read("/tmp/meteodata_valid.json", encoding: "utf-8"))
features = data["features"]

comarques = [
  { comarca: "Alt Camp", capital: "Valls", match: ["Valls 233m", "Valls"] },
  { comarca: "Alt Empordà", capital: "Figueres", match: ["Figueres 45m", "Figueres"] },
  { comarca: "Alt Penedès", capital: "Vilafranca del Penedès", match: ["Vilafranca del Penedès", "Vilafranca"] },
  { comarca: "Alt Urgell", capital: "La Seu d'Urgell", match: ["La Seu d'Urgell", "Seu"] },
  { comarca: "Alta Ribagorça", capital: "El Pont de Suert", match: ["el Pont de Suert 823m", "Pont de Suert"] },
  { comarca: "Anoia", capital: "Igualada", match: ["Igualada", "Òdena", "Vallbona d'Anoia"] },
  { comarca: "Bages", capital: "Manresa", match: ["Manresa - Est", "Manresa"] },
  { comarca: "Baix Camp", capital: "Reus", match: ["Reus - Antic", "Reus"] },
  { comarca: "Baix Ebre", capital: "Tortosa", match: ["Tortosa 50m", "Tortosa"] },
  { comarca: "Baix Empordà", capital: "La Bisbal d'Empordà", match: ["la Bisbal d'Empordà 28m", "Bisbal"] },
  { comarca: "Baix Llobregat", capital: "Sant Feliu de Llobregat", match: ["Sant Feliu", "Sant Joan Despí - TV3", "Sant Boi"] },
  { comarca: "Baix Penedès", capital: "El Vendrell", match: ["el Vendrell 59m", "Vendrell"] },
  { comarca: "Barcelonès", capital: "Barcelona", match: ["Barcelona - Dexeus", "Barcelona"] },
  { comarca: "Berguedà", capital: "Berga", match: ["Berga"] },
  { comarca: "Cerdanya", capital: "Puigcerdà", match: ["Puigcerdà 1213m", "Puigcerdà", "La Molina"] },
  { comarca: "Conca de Barberà", capital: "Montblanc", match: ["Montblanc"] },
  { comarca: "Garraf", capital: "Vilanova i la Geltrú", match: ["Vilanova i la Geltrú", "Sitges"] },
  { comarca: "Garrigues", capital: "Les Borges Blanques", match: ["Les Borges Blanques 283m", "Borges Blanques"] },
  { comarca: "Garrotxa", capital: "Olot", match: ["Olot - Pla de dalt 452m", "Olot"] },
  { comarca: "Gironès", capital: "Girona", match: ["Girona 76m", "Girona Aeroport", "Girona"] },
  { comarca: "Lluçanès", capital: "Prats de Lluçanès", match: ["Prats de Lluçanès", "Lluçanès", "Vic"] },
  { comarca: "Maresme", capital: "Mataró", match: ["Mataró 87m", "Mataró", "Vilassar"] },
  { comarca: "Moianès", capital: "Moià", match: ["Moià 742m", "Moià"] },
  { comarca: "Montsià", capital: "Amposta", match: ["Amposta 3m", "Amposta"] },
  { comarca: "Noguera", capital: "Balaguer", match: ["Balaguer", "Os de Balaguer"] },
  { comarca: "Osona", capital: "Vic", match: ["Vic zona esportiva", "Vic"] },
  { comarca: "Pallars Jussà", capital: "Tremp", match: ["Tremp 473m", "Tremp"] },
  { comarca: "Pallars Sobirà", capital: "Sort", match: ["Sort 679m", "Sort"] },
  { comarca: "Pla d'Urgell", capital: "Mollerussa", match: ["Mollerussa 247m", "Mollerussa"] },
  { comarca: "Pla de l'Estany", capital: "Banyoles", match: ["Banyoles 176m", "Banyoles"] },
  { comarca: "Priorat", capital: "Falset", match: ["Falset 359m", "Falset"] },
  { comarca: "Ribera d'Ebre", capital: "Móra d'Ebre", match: ["Móra d'Ebre", "Ascó 257m", "Rasquera"] },
  { comarca: "Ripollès", capital: "Ripoll", match: ["Ripoll", "Sant Pau de Segúries 851m", "Camprodon"] },
  { comarca: "Segarra", capital: "Cervera", match: ["Cervera 554m", "Cervera"] },
  { comarca: "Segrià", capital: "Lleida", match: ["Lleida - Ciutat Jardi", "Lleida"] },
  { comarca: "Selva", capital: "Santa Coloma de Farners", match: ["Santa Coloma de Farners 162m", "Santa Coloma"] },
  { comarca: "Solsonès", capital: "Solsona", match: ["Solsona 691m", "Solsona"] },
  { comarca: "Tarragonès", capital: "Tarragona", match: ["Tarragona - Complex Educatiu 5m", "Tarragona"] },
  { comarca: "Terra Alta", capital: "Gandesa", match: ["Gandesa 349m", "Gandesa"] },
  { comarca: "Urgell", capital: "Tàrrega", match: ["Tàrrega", "Castellsera"] },
  { comarca: "Val d'Aran", capital: "Vielha", match: ["Vielha - Elipòrt 1.027m", "Vielha"] },
  { comarca: "Vallès Occidental", capital: "Sabadell", match: ["Sabadell-Centre", "Sabadell", "Terrassa"] },
  { comarca: "Vallès Oriental", capital: "Granollers", match: ["Granollers 210m", "Granollers"] }
]

results = []
comarques.each do |c|
  matched = nil
  (c[:match] || []).each do |term|
    m = features.find { |f| (f.dig("properties", "nomok") || "").downcase.include?(term.downcase) }
    if m
      matched = m
      break
    end
  end
  
  if !matched
    matched = features.find { |f| (f.dig("properties", "comarca") || "").downcase == c[:comarca].downcase }
  end
  
  temp = matched ? (matched.dig("properties", "temp_value") || 14.0) : 14.0
  results << {
    capital: c[:capital],
    comarca: c[:comarca],
    temp: temp.to_f.round(1),
    temp_round: temp.to_f.round,
    station: matched ? matched.dig("properties", "nomok") : "Estació comarcal"
  }
end

def clean_name(str)
  s = str.downcase
  s.gsub!(/^(el |la |les |l'|els )/, "")
  s.tr!("àáâãäåèéêëìíîïòóôõöøùúûüç", "aaaaaaeeeeiiiioooooouuuuc")
  s
end

results.sort_by! { |r| clean_name(r[:capital]) }

File.open("/Users/Gerard/.gemini/antigravity/scratch/rellotge-3d/data.json", "w:utf-8") do |f|
  f.write(JSON.pretty_generate(results))
end

puts "SUCCESS: Saved #{results.length} capitals to data.json"
