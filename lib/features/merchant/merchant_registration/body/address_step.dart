import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/data/model/model.dart';
import '../core/form_validators.dart';
import '../core/registration_theme.dart';

class AddressStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final TextEditingController pincodeController;
  final String selectedState;
  final Function(String?) onStateChanged;
  final List<StateModel> states;

  const AddressStep({
    super.key,
    required this.formKey,
    required this.addressController,
    required this.pincodeController,
    required this.selectedState,
    required this.onStateChanged,
    required this.states,
  });

  @override
  State<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  final TextEditingController _searchController = TextEditingController();
  List<StateModel> _filteredStates = [];
  bool _isSearching = false;

  // Add keys for field-level showcases
  final GlobalKey _addressFieldKey = GlobalKey();
  final GlobalKey _pincodeFieldKey = GlobalKey();
  final GlobalKey _stateFieldKey = GlobalKey();

  void _showFieldShowcase(GlobalKey key) {
    setState(() {});
    ShowCaseWidget.of(context).startShowCase([key]);
  }

  @override
  void initState() {
    super.initState();
    _filteredStates = List.from(widget.states);
  }

  @override
  void didUpdateWidget(AddressStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.states != widget.states) {
      _filteredStates = List.from(widget.states);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStates(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStates = List.from(widget.states);
      } else {
        _filteredStates =
            widget.states
                .where(
                  (state) =>
                      state.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Showcase(
            key: _addressFieldKey,
            description:
                'Enter your complete address for business correspondence.',
            child: _buildAddressField(),
          ),
          const SizedBox(height: 16),
          Showcase(
            key: _pincodeFieldKey,
            description: 'Enter your area pincode (6 digits).',
            child: _buildPincodeField(),
          ),
          const SizedBox(height: 16),
          Showcase(
            key: _stateFieldKey,
            description: 'Select your state from the list.',
            child: _buildStateSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Icon(
                  CupertinoIcons.home,
                  color: RegistrationTheme.primaryColor,
                ),
              ),
              Expanded(
                child: CupertinoTextFormFieldRow(
                  controller: widget.addressController,
                  placeholder: 'Your Full Address *',
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  validator: FormValidators.requiredValidator,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: RegistrationTheme.bodyMedium(context: context),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 7,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
            icon: const Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 22,
            ),
            tooltip: 'What is Address?',
            onPressed: () => _showFieldShowcase(_addressFieldKey),
          ),
        ),
      ],
    );
  }

  Widget _buildPincodeField() {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  CupertinoIcons.location_circle,
                  color: RegistrationTheme.primaryColor,
                ),
              ),
              Expanded(
                child: CupertinoTextFormFieldRow(
                  controller: widget.pincodeController,
                  placeholder: 'Your Pincode *',
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  validator: FormValidators.pinCodeValidator,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: RegistrationTheme.bodyMedium(context: context),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 7,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
            icon: const Icon(
              Icons.info_outline,
              color: Colors.blueGrey,
              size: 22,
            ),
            tooltip: 'What is Pincode?',
            onPressed: () => _showFieldShowcase(_pincodeFieldKey),
          ),
        ),
      ],
    );
  }

  Widget _buildStateSelector(BuildContext context) {
    return Stack(
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'Select State *',
                  style: RegistrationTheme.bodyMedium(
                    context: context,
                    color: RegistrationTheme.secondaryTextColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showSearchableStatePicker(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          widget.selectedState.isEmpty
                              ? RegistrationTheme.errorColor.withValues(
                                alpha: 0.5,
                              )
                              : Colors.transparent,
                      width: widget.selectedState.isEmpty ? 1 : 0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.map,
                        color: RegistrationTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getStateName(widget.selectedState),
                          style: RegistrationTheme.bodyMedium(
                            context: context,
                            color:
                                widget.selectedState.isEmpty
                                    ? RegistrationTheme.secondaryTextColor
                                    : RegistrationTheme.primaryTextColor,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        color: RegistrationTheme.secondaryTextColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.selectedState.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(
                    'Please select a state',
                    style: TextStyle(
                      color: RegistrationTheme.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),

        Positioned(
          right: 24,
          top: 5,
          child: Material(
            child: InkWell(
              child: const Icon(
                Icons.info_outline,
                color: Colors.blueGrey,
                size: 20,
              ),
              onTap: () => _showFieldShowcase(_stateFieldKey),
            ),
          ),
        ),
      ],
    );
  }

  String _getStateName(String stateId) {
    if (stateId.isEmpty) return 'Select State';

    final state = widget.states.firstWhere(
      (state) => state.id == stateId,
      orElse: () => StateModel(id: '', name: 'Select State'),
    );
    return state.name;
  }

  void _showSearchableStatePicker(BuildContext context) {
    _searchController.clear();
    _filteredStates = List.from(widget.states);
    _isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select State',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search states...',
                      onChanged: (query) {
                        setState(() {
                          _filterStates(query);
                          _isSearching = query.isNotEmpty;
                        });
                      },
                      onSubmitted: (query) {
                        setState(() {
                          _filterStates(query);
                          _isSearching = query.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  // States list
                  Expanded(
                    child:
                        _filteredStates.isEmpty
                            ? const Center(
                              child: Text(
                                'No states found',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _filteredStates.length,
                              itemBuilder: (context, index) {
                                final state = _filteredStates[index];
                                final isSelected =
                                    widget.selectedState == state.id;

                                return GestureDetector(
                                  onTap: () {
                                    widget.onStateChanged(state.id);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? RegistrationTheme.primaryColor
                                                  .withOpacity(0.1)
                                              : null,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: CupertinoColors.systemGrey5,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          state.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color:
                                                isSelected
                                                    ? RegistrationTheme
                                                        .primaryColor
                                                    : null,
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            CupertinoIcons.checkmark_alt,
                                            color:
                                                RegistrationTheme.primaryColor,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
