class EditFavoritesResponse {
  final String message;

  EditFavoritesResponse({
    this.message,
  });

  EditFavoritesResponse.fromJson(Map<String, dynamic> json)
      : message = json['data'][0];
}
