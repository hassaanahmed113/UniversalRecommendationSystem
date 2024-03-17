import 'package:gsheets/gsheets.dart';
import 'package:universal_recommendation_system/util/sheetcolumn.dart';

class SheetsFlutter {
  static const String _sheetId = "13IjFWd2j3bA5iOZhyEUvjFAzVuUReqgHQfKeqb5Sr0w";
  static const _sheetCredentials = r'''
{
  "type": "service_account",
  "project_id": "universalrecommendationsys",
  "private_key_id": "cab3f7def4ee8b5834b18aa5cb71053b62763ba5",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCzBjvxxd9GyYTN\nrVqGiDnAX2qOT0PlevcHAh7aboy1YnMY+otz7NHZ/50ffzMJ5j0UhMa+uo5szUPd\nhk+QagyE4UKCC3aCvJd4geV2FB3NILSWsXtK95FO/N6hbc7KcVPz5iS+UgQZnuEG\nZNBn0/lcTceuCHtWxN5/bSokM8nJ6GiOzG5Sbsx/ujgwAO9DSxTTbscUQWP7/JsV\nTeZ13Id2HF4dJEXaK4TXvPp0XonivPXTSHCes2PEFJ9MTrmQ/oyf6wNSFP8ZRw1v\nB8e7YFufvMpgOrd88BqHxCAQYBChyHTp46sNgWhFVBl9sCNqrROz9gX0YsS7ni0O\nJrcxER5xAgMBAAECggEACQl4Rq7eo7/h8pD86Bwh0C5w3lCthHzF0gZ/ILciZria\nx0jEd9xdRoQi/hdJcAc9j5bZQoD/1gmxkpHoW8miqqWFWjOyboyPF9/0wZZn37Y2\nL4Izj1f6b5KPuXXl0a3RV1dHhQz2VIXC5bP6mjcm2Aw8F3KpqTpkYenUjgHIPqcl\nW8AZEQrrjMhdde5uEx95Ku/RFTUFiOmBG6NqZ7No3uZHVQONDZZFrczZGUDY7JvF\npRpkKz3/z7vKfISWrw5YE6g3qbNSjrObmdTPnbgEBkrugOMxDhZ9sQRGDy8fFiaz\nfP5PtoISy4TJYp4Kxlh30DdQRQzAuroTjY0VNCRtXQKBgQDaqbiWmcaVyQ5VU2xT\n2tW8vrODP+PbLp/XpDs93nribdRTj3jddGfLOyeGhLmfc8UD0IdzoMvYXKQh589S\nTQu1ud/iEHnBIiZ7iVGsq2b7V8kI2jYjPX999IjCbSs9DMGVXlmbCwV+KU8tkRj8\nZbNhGPuGsttC2L5a3dMl0H6nLQKBgQDRl9CNtq9TYynEssOJ+Tyoi9L2NpgYFKXU\ng0Z2cEdtBbdbaiQKqFOsmxeUPEHBhV/3XBu3oKpF4Jy3U/iCqrq/EJS6xQ+MCs7o\nfilLGFwiwfLhv3WK1/Tz0rUaAjfD8vxC1LNPiQKm/hXWSK5WNkS6E+/C6wOgVnW1\nULhC3/Pe1QKBgGj+DW/iroPFYmh+AgnRjcdvGervhoz7uixk4z010nNeoRDuVu6e\nsifXY4cnu6lggTzvp9pRXw+oi/brw5SVAgZkFagKmSuvJiMzMFBkjLIq2JCzlkMd\niFYGUJRqrtRFh74c65GSnTSSyT3r6b9nZdY9lKh8wOM8B0rCMFx73BSRAoGADeiS\nKWVPGyyAcBIg0b4dXV3yAO68hxSPsJuJiICI7N4tPb68Z4ymCNU96lNZVbtBFAwj\ntrrNsddm7u9+lUU5IUa7Z+19y6BH/Luqh9Y0/wV51as75JvSIIACDpjJFJLCVLkC\nsSt5ZpWD43VtREFTrDl4dqnb0r8KDp8tqxprd4UCgYBz2DqNbDZkEHTMI/hriJOi\nlGkLytJIVOo6q7Xo167MpzXQzw8YnkdvtOo+B1oyzup3qaiXQcTpXZURpNHAzz4L\nREwqg9+mRWUd2PKT/MNF/FXEVlmACuZN3pIaBmJJxKLI+GT/QXCFLD4uuGVhK9Yf\nJdnfhlwdyKw7cuUQ2Bagdw==\n-----END PRIVATE KEY-----\n",
  "client_email": "urssheet@universalrecommendationsys.iam.gserviceaccount.com",
  "client_id": "103865660652248770369",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/urssheet%40universalrecommendationsys.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
  static Worksheet? _userSheet;
  static final _gsheets = GSheets(_sheetCredentials);

  static Future init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_sheetId);

      _userSheet = await _getWorkSheet(spreadsheet, title: "FeedbackSheetURS");
      final firstRow = SheetsColumn.getColumns();
      _userSheet!.values.insertRow(1, firstRow);
    } catch (e) {
      print(e);
    }
  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
    }
  }

  static Future insert(List<Map<String, dynamic>> rowList) async {
    _userSheet!.values.map.appendRows(rowList);
  }
}
