require 'sequel'
DB = Sequel.connect('mysql2://root:root@127.0.0.1:3306/arduino')

current_valuation = 0
current_karma = 0

points = []

SCHEDULER.every '10s' do

  points.shift
  DB["select 1 x, consumo_por_hora y from consumo ORDER BY data DESC LIMIT 10"].each do |row|
    points << row
    p row
  end

  send_event('convergence', points: points)

  sql = "select DATE_FORMAT(data,'%d %b %y') label, consumo_por_hora value
         from consumo
         where data is not null and data <> '0000-00-00 00:00:00'
         ORDER BY consumo_por_hora DESC
         LIMIT 10"

  buzzItems = []
  DB[sql].each do |row|
    buzzItems << row
  end

  send_event('buzzwords', { items: buzzItems })

  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = rand(100)
  current_karma     = rand(200000)

  # send_event('valuation', { current: current_valuation, last: last_valuation })
  # send_event('karma', { current: current_karma, last: last_karma })
  dataset = DB['select 1 from consumo']
  send_event('synergy',  { value: dataset.count })
end
