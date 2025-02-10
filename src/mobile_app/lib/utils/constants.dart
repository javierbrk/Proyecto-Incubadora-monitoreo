class ApiConstants {
  static String baseUrl = 'http://192.168.16.10';
  static String rotationEndPoint = '/rotation';
  static String actualEndPoint = '/actual';
  static String wifiEndPoint = '/wifi';
  static String configEndPoint = '/config';
  
  static String getGrafanaUrl(String incubadoraId) {
      return 'https://grafana.altermundi.net/d/2ebcKhKHz/visor-incubadoras-librepollo?orgId=2&refresh=5s&var-incubadora=$incubadoraId&kiosk';
    }
}
