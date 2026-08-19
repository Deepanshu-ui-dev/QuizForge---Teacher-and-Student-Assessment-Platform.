class Pagination {
  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  final int page;
  final int limit;
  final int total;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 10,
        total: json['total'] as int? ?? 0,
        pages: json['pages'] as int? ?? 1,
        hasNext: json['hasNext'] as bool? ?? false,
        hasPrev: json['hasPrev'] as bool? ?? false,
      );
}

class PaginatedResult<T> {
  const PaginatedResult({required this.data, required this.pagination});
  final List<T> data;
  final Pagination pagination;
}
