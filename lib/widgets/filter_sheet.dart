import 'package:flutter/material.dart';
import '../theme.dart';

class FilterSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;

  const FilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<String> _selectedStatuses;
  late String _country;
  late String _deliverySpeed;
  late Set<String> _selectedPriorities;
  late Set<String> _selectedTags;
  DateTime? _deadlineFrom;
  DateTime? _deadlineTo;

  final List<String> _allStatuses = [
    'Script Review',
    'Script Approved',
    'In Progress',
    'Preview Sent',
    'Completed',
    'Draft',
  ];
  final List<String> _allPriorities = ['Normal', 'High', 'VIP'];
  final List<String> _allTags = [
    'Birthday',
    'Anniversary',
    'Wedding',
    'Proposal',
    'Romantic',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _selectedStatuses = Set<String>.from(f['statuses'] ?? []);
    _country = f['country'] ?? '';
    _deliverySpeed = f['deliverySpeed'] ?? '';
    _selectedPriorities = Set<String>.from(f['priorities'] ?? []);
    _selectedTags = Set<String>.from(f['tags'] ?? []);
    _deadlineFrom = f['deadlineFrom'];
    _deadlineTo = f['deadlineTo'];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Filter Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle('Status'),
                    ..._allStatuses.map((s) => CheckboxListTile(
                          title: Text(s),
                          value: _selectedStatuses.contains(s),
                          activeColor: AppColors.primary,
                          dense: true,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedStatuses.add(s);
                              } else {
                                _selectedStatuses.remove(s);
                              }
                            });
                          },
                        )),
                    const SizedBox(height: 16),
                    _sectionTitle('Priority'),
                    ..._allPriorities.map((p) => CheckboxListTile(
                          title: Text(p),
                          value: _selectedPriorities.contains(p),
                          activeColor: AppColors.primary,
                          dense: true,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedPriorities.add(p);
                              } else {
                                _selectedPriorities.remove(p);
                              }
                            });
                          },
                        )),
                    const SizedBox(height: 16),
                    _sectionTitle('Delivery Speed'),
                    Row(
                      children: [
                        _choiceChip('Standard'),
                        const SizedBox(width: 8),
                        _choiceChip('Express'),
                        const SizedBox(width: 8),
                        _choiceChip('Any', isAny: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Tags'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _allTags
                          .map((t) => FilterChip(
                                label: Text(t),
                                selected: _selectedTags.contains(t),
                                selectedColor: AppColors.primary.withOpacity(0.15),
                                checkmarkColor: AppColors.primary,
                                onSelected: (v) {
                                  setState(() {
                                    if (v) {
                                      _selectedTags.add(t);
                                    } else {
                                      _selectedTags.remove(t);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Country'),
                    TextFormField(
                      initialValue: _country,
                      decoration: const InputDecoration(
                        hintText: 'e.g. United States',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      onChanged: (v) => _country = v,
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Deadline Range'),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_deadlineFrom == null
                                ? 'From'
                                : '${_deadlineFrom!.day}/${_deadlineFrom!.month}/${_deadlineFrom!.year}'),
                            onPressed: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_deadlineTo == null
                                ? 'To'
                                : '${_deadlineTo!.day}/${_deadlineTo!.month}/${_deadlineTo!.year}'),
                            onPressed: () => _pickDate(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _choiceChip(String label, {bool isAny = false}) {
    final selected = isAny ? _deliverySpeed.isEmpty : _deliverySpeed == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary.withOpacity(0.15),
      onSelected: (_) {
        setState(() {
          _deliverySpeed = isAny ? '' : label;
        });
      },
    );
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _deadlineFrom = picked;
        } else {
          _deadlineTo = picked;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedStatuses.clear();
      _country = '';
      _deliverySpeed = '';
      _selectedPriorities.clear();
      _selectedTags.clear();
      _deadlineFrom = null;
      _deadlineTo = null;
    });
  }

  void _applyFilters() {
    widget.onApply({
      'statuses': _selectedStatuses.toList(),
      'country': _country,
      'deliverySpeed': _deliverySpeed,
      'priorities': _selectedPriorities.toList(),
      'tags': _selectedTags.toList(),
      'deadlineFrom': _deadlineFrom,
      'deadlineTo': _deadlineTo,
    });
    Navigator.pop(context);
  }
}
