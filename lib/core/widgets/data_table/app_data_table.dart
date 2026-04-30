import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum TableDensity { compact, comfortable, spacious }

class DataTableColumn<T> {
  final String label;
  final String? field;
  final double? width;
  final bool sortable;
  final Widget Function(T row) builder;

  const DataTableColumn({
    required this.label,
    this.field,
    this.width,
    this.sortable = false,
    required this.builder,
  });
}

class PaginationConfig {
  final int page;
  final int pageSize;
  final int total;
  final List<int> pageSizes;
  final void Function(int page) onPageChanged;
  final void Function(int size) onPageSizeChanged;

  const PaginationConfig({
    required this.page,
    required this.pageSize,
    required this.total,
    this.pageSizes = const [20, 50, 100],
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });
}

class SortConfig {
  final String? field;
  final bool ascending;
  final void Function(String field, bool ascending) onSort;

  const SortConfig({
    this.field,
    this.ascending = true,
    required this.onSort,
  });
}

class AppDataTable<T> extends StatefulWidget {
  final List<T> rows;
  final List<DataTableColumn<T>> columns;
  final bool selectable;
  final Function(List<T>)? onSelectionChanged;
  final Function(T)? onRowTap;
  final Function(T)? onRowDoubleTap;
  final Widget Function(T)? rowActionsBuilder;
  final bool isLoading;
  final String? emptyMessage;
  final TableDensity density;
  final PaginationConfig? pagination;
  final SortConfig? sort;

  const AppDataTable({
    super.key,
    required this.rows,
    required this.columns,
    this.selectable = true,
    this.onSelectionChanged,
    this.onRowTap,
    this.onRowDoubleTap,
    this.rowActionsBuilder,
    this.isLoading = false,
    this.emptyMessage,
    this.density = TableDensity.comfortable,
    this.pagination,
    this.sort,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  final Set<int> _selectedIndexes = {};
  int? _lastSelectedIndex;

  double get _rowHeight {
    switch (widget.density) {
      case TableDensity.compact:
        return 36;
      case TableDensity.comfortable:
        return 44;
      case TableDensity.spacious:
        return 56;
    }
  }

  List<T> get _selectedRows =>
      _selectedIndexes.map((i) => widget.rows[i]).toList();

  void _toggleSelect(int index, {bool ctrl = false, bool shift = false}) {
    setState(() {
      if (shift && _lastSelectedIndex != null) {
        final start = _lastSelectedIndex! < index
            ? _lastSelectedIndex!
            : index;
        final end = _lastSelectedIndex! < index
            ? index
            : _lastSelectedIndex!;
        for (var i = start; i <= end; i++) {
          _selectedIndexes.add(i);
        }
      } else if (ctrl) {
        if (_selectedIndexes.contains(index)) {
          _selectedIndexes.remove(index);
        } else {
          _selectedIndexes.add(index);
        }
      } else {
        _selectedIndexes
          ..clear()
          ..add(index);
      }
      _lastSelectedIndex = index;
    });
    widget.onSelectionChanged?.call(_selectedRows);
  }

  void _toggleAll(bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedIndexes
            .addAll(List.generate(widget.rows.length, (i) => i));
      } else {
        _selectedIndexes.clear();
      }
    });
    widget.onSelectionChanged?.call(_selectedRows);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildShimmer();
    if (widget.rows.isEmpty) return _buildEmpty();

    return Column(
      children: [
        Expanded(child: _buildTable()),
        if (widget.pagination != null) _buildPagination(widget.pagination!),
      ],
    );
  }

  Widget _buildTable() {
    return DataTable2(
      headingRowHeight: 40,
      dataRowHeight: _rowHeight,
      columnSpacing: 16,
      horizontalMargin: 16,
      headingRowColor: WidgetStateProperty.all(AppColors.neutral100),
      dividerThickness: 1,
      border: TableBorder(
        bottom: BorderSide(color: AppColors.neutral200),
        horizontalInside: BorderSide(color: AppColors.neutral100),
      ),
      sortColumnIndex: widget.sort?.field != null
          ? widget.columns
              .indexWhere((c) => c.field == widget.sort!.field)
          : null,
      sortAscending: widget.sort?.ascending ?? true,
      onSelectAll: widget.selectable ? _toggleAll : null,
      columns: [
        ...widget.columns.map(
          (col) => DataColumn2(
            label: Text(
              col.label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            size: col.width != null
                ? ColumnSize.S
                : ColumnSize.M,
            fixedWidth: col.width,
            onSort: col.sortable && col.field != null && widget.sort != null
                ? (_, ascending) =>
                    widget.sort!.onSort(col.field!, ascending)
                : null,
          ),
        ),
        if (widget.rowActionsBuilder != null)
          const DataColumn2(label: SizedBox.shrink(), size: ColumnSize.S, fixedWidth: 48),
      ],
      rows: widget.rows.asMap().entries.map((entry) {
        final i = entry.key;
        final row = entry.value;
        final isSelected = _selectedIndexes.contains(i);

        return DataRow2(
          selected: isSelected,
          color: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.neutral50;
            }
            if (isSelected) return AppColors.primaryLight.withAlpha(60);
            return null;
          }),
          onTap: () {
            final ctrl = HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed;
            final shift = HardwareKeyboard.instance.isShiftPressed;
            if (widget.selectable) _toggleSelect(i, ctrl: ctrl, shift: shift);
            widget.onRowTap?.call(row);
          },
          onDoubleTap: widget.onRowDoubleTap != null
              ? () => widget.onRowDoubleTap!(row)
              : null,
          cells: [
            ...widget.columns.map(
              (col) => DataCell(col.builder(row)),
            ),
            if (widget.rowActionsBuilder != null)
              DataCell(widget.rowActionsBuilder!(row)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral100,
      highlightColor: AppColors.neutral50,
      child: Column(
        children: [
          Container(height: 40, color: AppColors.neutral100),
          ...List.generate(
            8,
            (_) => Container(
              height: _rowHeight,
              margin: const EdgeInsets.only(top: 1),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined,
              size: 48, color: AppColors.neutral300),
          const SizedBox(height: 12),
          Text(
            widget.emptyMessage ?? 'No data',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(PaginationConfig p) {
    final start = (p.page - 1) * p.pageSize + 1;
    final end = (p.page * p.pageSize).clamp(0, p.total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $start–$end of ${_fmt(p.total)}',
            style: AppTypography.caption.copyWith(color: AppColors.neutral500),
          ),
          const Spacer(),
          Text('Rows:', style: AppTypography.caption),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: p.pageSize,
            isDense: true,
            underline: const SizedBox.shrink(),
            items: p.pageSizes
                .map((s) =>
                    DropdownMenuItem(value: s, child: Text('$s')))
                .toList(),
            onChanged: (v) => v != null ? p.onPageSizeChanged(v) : null,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            onPressed: p.page > 1 ? () => p.onPageChanged(p.page - 1) : null,
            visualDensity: VisualDensity.compact,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${p.page} / ${((p.total - 1) ~/ p.pageSize) + 1}',
              style: AppTypography.caption,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            onPressed: end < p.total
                ? () => p.onPageChanged(p.page + 1)
                : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final sb = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) sb.write(',');
        sb.write(s[i]);
      }
      return sb.toString();
    }
    return n.toString();
  }
}
