class InicioControllerTest < ActionController::TestCase
  def setup
    @cryptomonedas = []
  end

  # Probar si la app responde sin errores a la petición de inicio#index
  test "should get index" do
    get :index
    assert_response :success
  end

  # Probar si la app responde sin errores a la petición de generar el archivo JSON desde inicio#index
  test "should get index:json" do
    get :index, :format => :json
    assert_response :success
  end

  # Probar si la app responde sin errores a la petición de generar el archivo CSV desde inicio#index
  test "should get index:csv" do
    get :index, :format => :csv
    assert_response :success
  end
end