require 'pg'

def db
 db_config = {
   host: 'localhost',
   user: 'postgres',
   password: 'tenmaruten',
   dbname: 'discord',
   port: 5432
 }
 connection = PG.connect(db_config)
 connection.internal_encoding = 'UTF-8'
 return connection
end

def hiyokoBox(name)
  hiyoko = den = mol = total = total_persent = 0 #クリア
  per = ""
  connection = db() #db接続
  begin
    insert = connection.exec("INSERT INTO hiyoko (name, random, toro, hiyoko, total) VALUES ($1, 1, 0, 0, 0)", [name]) #行作成
    return "作成完了：\n名前 #{name} / 確率 100%(1分の1） / 中トロ 0貫 / ひよこ 0体 " #初期値なので平打ち
  rescue
    result = connection.exec("SELECT * FROM hiyoko WHERE name = $1", [name]) #insertでエラーが出たらもうあるのでselect
    result.each do |record|
      den = record['random']
      mol = record['toro']
      hiyoko = record['hiyoko']
      total = record['total']
    end
    if total != "0" && hiyoko != "0" then
      total_persent = percentage(total,hiyoko.to_i - 1)
      per = '%'
    else
      total_persent = "データがありません"
    end
    return "#{name}さんのボックス：\nひよこ確率 #{((mol.to_f + 1) / den.to_f) * 100 }%（#{den}分の#{mol.to_i + 1}） / 中トロ #{mol}貫 / ひよこ #{hiyoko}体 / 試行回数 #{total}回 / ひよこ的中確率 #{total_persent}#{per}"
  end
end

def hiyokoGacha(name)
  hiyoko = den = mol = total = 0
  namecpy = ""
  connection = db()
  result = connection.exec("SELECT * FROM hiyoko WHERE name = $1", [name]) #全部使うよ
  result.each do |record|
    namecpy = record['name'] #DBから持ってきた名前と照会するために違う変数に
    den = record['random']
    mol = record['toro']
    hiyoko = record['hiyoko']
    total = record['total']
  end
  if namecpy == name then #これが無いとボックスが無くても引ける
    update = connection.exec("UPDATE hiyoko SET total = $1 WHERE name = $2",[total.to_i + 1, name])
    if mol.to_i >= rand(den.to_i) then #正しい確率計算法だと祈っている
      hiyoko = hiyoko.to_i + 1 #ひよこの数を増やしてる
      update = connection.exec("UPDATE hiyoko SET random = $1, hiyoko = $2 WHERE name = $3", [den.to_i * 2, hiyoko, name]) #確率とひよこの数をupdateしてる
      return "これはひよこ！ｗ\n\nおめでとう！#{name}さんはひよこを#{percentage(den,mol)}%（#{den}分の#{mol.to_i + 1}）の確率で当てました！\n現在の所持ひよこ #{hiyoko}体 / 次回の確率 #{percentage(den.to_i * 2,mol)}%（#{den.to_i * 2}分の#{mol.to_i + 1}）"
    elsif 20 >= rand(100) then #20%固定で中トロ引く
      mol = mol.to_i + 1
      update = connection.exec("UPDATE hiyoko SET toro = $1 WHERE name = $2", [mol, name])
      return "中トロｗ！！\n\n中トロを食べてひよこ的中率を上げよう！一貫につき確率が上がります\n現在所持している中トロ #{mol}貫 /今回の上昇値 #{one_percentage(den)}% / 合計ひよこ確率 #{percentage(den,mol)}%（#{den}分の#{mol.to_i + 1}）"
    else
      return "これはひよこじゃない…"
    end
  else
    return "#{name}さんのボックスがありません。「ひよこボックス」でボックスを作りましょう。"
  end
end

def percentage(den, mol)
  return ((mol.to_f + 1) / den.to_f) * 100
end

def one_percentage(den)
  return (1 / (den.to_f)) * 100
end
