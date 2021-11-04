class InicioController < ApplicationController
  # Invocamos la gema csv (forma parte del core de rails, así que al instalar rails va incluida esta gema)
  # para poder leer y crear archivos con formato csv
  require 'csv'

  def index

    # Invocamos la gema rest-client la cual agregamos via "bundle add rest-client" cuando creamos la app
    # para poder consumir recursos de una API externa, en este caso la de Messari API.
    require 'rest-client'

    # traemos los datos del API de Messari y lo pasamos a JSON
    response = RestClient.get("https://data.messari.io/api/v2/assets?with-metrics")
    results = JSON.parse(response.to_str)

    # leemos los datos del archivo CSV y llenamos una variable Hash (@cryptomonedas) con los datos de la API + los datos del archivo CSV
    @cryptomonedas = []
    CSV.foreach("origen.csv", headers: true, encoding:'iso-8859-1:utf-8', header_converters: :symbol) do |moneda|
      if moneda[0] == "Ether"
        moneda[0] = "Ethereum"
      end
      if params[:inversion].to_f > 0.0
        inversion = params[:inversion].to_f
      else
        inversion = moneda[2].to_f
      end

      # Los datos que nos devolvió la API de Messari las asignamos a variables que nos van a servir en el momento en que enviémos
      # los datos a la vista
      price = results["data"].find {|crypto| crypto['slug']==moneda[0].downcase}['metrics']['market_data']['price_usd']
      symbol = results["data"].find {|crypto| crypto['slug']==moneda[0].downcase}['symbol']
      change_24h =results["data"].find {|crypto| crypto['slug']==moneda[0].downcase}['metrics']['market_data']['percent_change_usd_last_24_hours']
      volume_24h =results["data"].find {|crypto| crypto['slug']==moneda[0].downcase}['metrics']['market_data']['real_volume_last_24_hours']

      # Hacemos los calculos del rendimiento
      mensual_crypto = ( inversion / price ) * (moneda[1].to_f / 100)
      mensual_usd = mensual_crypto * price
      anual_crypto = mensual_crypto * 12
      anual_usd = anual_crypto * price

      # Creamos el Hash con los datos que enviaremos a la vista
      @cryptomonedas.push( "symbol" => symbol, "moneda" => moneda[0], "price" => price, "interes_mensual" => moneda[1],
        "balance_inicial" => moneda[2].to_f, "mensual_crypto" => mensual_crypto, "anual_crypto" => anual_crypto,
        "mensual_usd" => mensual_usd, "anual_usd" => anual_usd, "inversion" => inversion,
        "change_24h" => change_24h, "volume_24h" => volume_24h)
    end

    # Enviamos los datos en 3 formatos (HTML, CSV y JSON)
    respond_to do |format|
     format.html
     format.csv { send_data @cryptomonedas.to_csv, filename: "crypto#{Time.now.strftime('%Y%m%d%H%M%S')}.csv" }
     format.json { send_data @cryptomonedas.to_json, filename: "crypto#{Time.now.strftime('%Y%m%d%H%M%S')}.json" }
    end
  end

  private
    def moneda_params
      # por seguridad recibimos únicamente los parámetros válidos de la vista
      params.require(:moneda).permit(:investment, :cryptomonedas)
    end
end

