import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pack/pack.dart'; // Assuming ImageView is from here
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import '../../../../core/domain/data_store/category_store.dart';
import '../../../../core/domain/data_store/service_store.dart';
import '../../../../core/data/model/product/category_model.dart';
import '../../../../core/data/model/product/service_model.dart';

class CategoryAndServicesStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? selectedCategoryId;
  final String? selectedServiceId;
  final Function(CategoryModel?) onCategorySelected;
  final Function(ServiceModel?) onServicesSelected;
  final VoidCallback resetForm;

  const CategoryAndServicesStep({
    super.key,
    required this.formKey,
    required this.selectedCategoryId,
    required this.selectedServiceId,
    required this.onCategorySelected,
    required this.onServicesSelected,
    required this.resetForm,
  });

  @override
  State<CategoryAndServicesStep> createState() =>
      _CategoryAndServicesStepState();
}

class _CategoryAndServicesStepState extends State<CategoryAndServicesStep> {
  String? errorCategories;
  String? errorServices;

  bool isLoadingCategories = false;
  bool isLoadingServices = false;

  List<CategoryModel> allCategories = [];
  List<ServiceModel> allServicesForCategory = [];

  // Filter, sort & search
  List<CategoryModel> filteredCategories = [];
  List<ServiceModel> filteredServices = [];
  String categorySearch = '';
  String serviceSearch = '';
  String categorySort = 'A-Z';
  String serviceSort = 'A-Z';

  // Use TextEditingControllers for search fields to manage text state independently
  final TextEditingController _categorySearchController =
      TextEditingController();
  final TextEditingController _serviceSearchController =
      TextEditingController();

  CategoryModel selectedCategory = CategoryModel.empty();
  ServiceModel selectedServices = ServiceModel.empty();

  // For quick UI updates in search modal for the LISTS/GRIDS only
  final ValueNotifier<void> _categoryFilterNotifier = ValueNotifier(null);
  final ValueNotifier<void> _serviceFilterNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _categorySearchController.addListener(() {
      // Update search string when controller changes, but don't call setState here
      if (categorySearch != _categorySearchController.text) {
        categorySearch = _categorySearchController.text;
        _applyCategorySearchAndSort(); // Trigger filter update
      }
    });
    _serviceSearchController.addListener(() {
      // Update search string when controller changes, but don't call setState here
      if (serviceSearch != _serviceSearchController.text) {
        serviceSearch = _serviceSearchController.text;
        _applyServiceSearchAndSort(); // Trigger filter update
      }
    });
    _fetchCategories();
    // Defer initial selection until after first frame and categories are potentially loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedCategoryId != null && allCategories.isNotEmpty) {
        _fetchAndSelectCategory(widget.selectedCategoryId!);
      }
    });
  }

  @override
  void dispose() {
    _categorySearchController.dispose();
    _serviceSearchController.dispose();
    _categoryFilterNotifier.dispose();
    _serviceFilterNotifier.dispose();
    super.dispose();
  }

  void _fetchCategories() async {
    setState(() {
      isLoadingCategories = true;
      errorCategories = null;
    });
    try {
      // Ensure context is available if called early
      if (!mounted) return;
      final store = context.read<CategoryStore>();
      // Make sure store data is ready if needed, or handle loading state within store
      // await store.fetchCategoriesIfNeeded(); // Example if store lazy loads
      final categories = List<CategoryModel>.from(store.allCategories);

      if (!mounted) return;
      setState(() {
        isLoadingCategories = false;
        allCategories = categories;
        _applyCategorySearchAndSort(); // Apply initial sort/filter

        // If an initial category was provided, select it now that categories are loaded
        if (widget.selectedCategoryId != null && selectedCategory.isEmpty) {
          _fetchAndSelectCategory(widget.selectedCategoryId!);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorCategories = 'Failed to load categories: ${e.toString()}';
        isLoadingCategories = false;
        allCategories = [];
        filteredCategories = [];
      });
    }
  }

  void _fetchAndSelectCategory(String categoryId) {
    // Check if categories are loaded
    if (allCategories.isEmpty) {
      // Categories not loaded yet, maybe wait or handle error
      dev.log(
        "Warning: Trying to select category before categories are loaded.",
      );
      return;
    }
    final cat = allCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel.empty(),
    );
    // Only proceed if a valid category was found and it's different from current
    if (cat.id.isNotEmpty && selectedCategory.id != cat.id) {
      _onCategoryPicked(cat);
    } else if (cat.isEmpty) {
      dev.log("Warning: Category with ID $categoryId not found.");
      // Optionally reset selection if the provided ID is invalid
      // _handleClear();
    }
  }

  void _onCategoryPicked(CategoryModel cat) async {
    // Check if it's actually a new category
    if (selectedCategory.id == cat.id) return;

    setState(() {
      selectedCategory = cat;
      widget.onCategorySelected(cat); // Notify parent

      // Reset service state
      isLoadingServices = true;
      errorServices = null;
      selectedServices = ServiceModel.empty(); // Reset service selection
      widget.onServicesSelected(null); // Notify parent about service reset
      allServicesForCategory = [];
      filteredServices = [];
      serviceSearch = ''; // Reset service search
      _serviceSearchController.clear(); // Clear search field text
      _serviceFilterNotifier.value = null; // Notify service list listener
    });

    // Fetch services for the newly selected category
    await _fetchServicesForCategory(cat.id);

    // Pre-select service if needed, after services are fetched
    if (widget.selectedServiceId != null &&
        selectedCategory.id == widget.selectedCategoryId) {
      _selectInitialService(widget.selectedServiceId!);
    }
  }

  Future<void> _fetchServicesForCategory(String categoryId) async {
    try {
      // Ensure context is available
      if (!mounted) return;
      final store = context.read<ServiceStore>();
      // Filter services based on the *correct* categoryId type (ensure it's string comparison if needed)
      final all = List<ServiceModel>.from(
        store.items.where((srv) => srv.categoryId.toString() == categoryId),
      );

      if (!mounted) return;
      setState(() {
        allServicesForCategory = all;
        isLoadingServices = false;
        _applyServiceSearchAndSort(); // Apply initial sort/filter
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorServices = 'Failed to load services: ${e.toString()}';
        isLoadingServices = false;
        allServicesForCategory = [];
        filteredServices = [];
      });
    }
  }

  void _selectInitialService(String serviceId) {
    // Ensure services for the category are loaded
    if (allServicesForCategory.isEmpty && !isLoadingServices) {
      dev.log(
        "Warning: Trying to select service before services are loaded or category has no services.",
      );
      return;
    }
    if (isLoadingServices) {
      // Services still loading, selection will be handled after fetch completes if needed
      return;
    }

    final service = allServicesForCategory.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => ServiceModel.empty(),
    );

    if (!service.isEmpty && selectedServices.id != service.id) {
      setState(() {
        selectedServices = service;
        widget.onServicesSelected(service); // Notify parent
      });
    } else if (service.isEmpty) {
      dev.log(
        "Warning: Service with ID $serviceId not found in category ${selectedCategory.id}.",
      );
      // Optionally clear selection if ID is invalid for this category
      // setState(() {
      //   selectedServices = ServiceModel.empty();
      //   widget.onServicesSelected(null);
      // });
    }
  }

  // SEARCH & SORT HANDLERS

  void _applyCategorySearchAndSort() {
    List<CategoryModel> result = List.from(allCategories);
    final searchLower = categorySearch.toLowerCase(); // Use controller's text

    if (searchLower.isNotEmpty) {
      result =
          result
              .where((cat) => cat.title.toLowerCase().contains(searchLower))
              .toList();
    }

    if (categorySort == 'A-Z') {
      result.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (categorySort == 'Z-A') {
      result.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
    }

    // Check if mounted before updating state implicitly via notifier
    if (mounted) {
      // Update the filtered list variable used by the builder
      filteredCategories = result;
      // Notify the ValueListenableBuilder to rebuild the list/grid
      _categoryFilterNotifier.value = null; // Use notifyListeners()
    }
  }

  void _applyServiceSearchAndSort() {
    List<ServiceModel> result = List.from(allServicesForCategory);
    final searchLower = serviceSearch.toLowerCase(); // Use controller's text

    if (searchLower.isNotEmpty) {
      result =
          result
              .where(
                (svc) => svc.serviceName.toLowerCase().contains(searchLower),
              )
              .toList();
    }

    if (serviceSort == 'A-Z') {
      result.sort(
        (a, b) =>
            a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase()),
      );
    } else if (serviceSort == 'Z-A') {
      result.sort(
        (a, b) =>
            b.serviceName.toLowerCase().compareTo(a.serviceName.toLowerCase()),
      );
    }

    // Check if mounted before updating state implicitly via notifier
    if (mounted) {
      // Update the filtered list variable used by the builder
      filteredServices = result;
      // Notify the ValueListenableBuilder to rebuild the list/grid
      _serviceFilterNotifier.value = null; // Use notifyListeners()
    }
  }

  void _openCategorySheet() async {
    // Reset search text IF desired when opening, or keep previous search
    // _categorySearchController.clear(); // Optional: Clear search on open
    // categorySearch = '';             // Optional: Clear search state variable
    _applyCategorySearchAndSort(); // Ensure list is correctly filtered/sorted before showing

    showCupertinoModalPopup(
      context: context,
      builder: (modalContext) {
        // Use a different context name
        // Use StatefulBuilder for local UI updates within the modal (like dropdown)
        return StatefulBuilder(
          builder: (context, modalSetState) {
            // Local state setter
            return AnimatedContainer(
              // ... (rest of AnimatedContainer setup) ...
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Material(
                child: SafeArea(
                  top: false,
                  child:
                      isLoadingCategories
                          ? Center(child: CupertinoActivityIndicator())
                          : (errorCategories != null)
                          ? Center(child: Text(errorCategories!))
                          : Column(
                            children: [
                              // Sticky Search & Sort Row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CupertinoSearchTextField(
                                        // Use the controller
                                        controller: _categorySearchController,
                                        placeholder: 'Search categories...',
                                        // onChanged IS NOT NEEDED here anymore, listener handles it
                                        // onChanged: (v) {
                                        //   // !! NO modalSetState or setState HERE !!
                                        //   categorySearch = v;
                                        //   _applyCategorySearchAndSort();
                                        // },
                                        autocorrect: false,
                                        // suffixMode: OverlayVisibilityMode.editing, // Or always if preferred
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    DropdownButton<String>(
                                      value: categorySort,
                                      // ... (Dropdown styling) ...
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.label
                                            .resolveFrom(context),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      items:
                                          ['A-Z', 'Z-A']
                                              .map(
                                                (val) => DropdownMenuItem(
                                                  value: val,
                                                  child: Text('Sort: $val'),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val != null &&
                                            categorySort != val) {
                                          // Use modalSetState ONLY to update the dropdown's visual state
                                          modalSetState(() {
                                            categorySort = val;
                                          });
                                          // Apply the sort (which notifies the ValueListenableBuilder)
                                          _applyCategorySearchAndSort();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                // ValueListenableBuilder listens to the notifier
                                // It rebuilds ONLY this list part when notifier fires
                                child: ValueListenableBuilder<void>(
                                  valueListenable: _categoryFilterNotifier,
                                  builder: (_, __, ___) {
                                    // Context, value, child
                                    // Now use filteredCategories directly
                                    if (filteredCategories.isEmpty) {
                                      return Center(
                                        child: Text(
                                          categorySearch.isEmpty
                                              ? "No categories found"
                                              : "No results for \"$categorySearch\"",
                                          style: TextStyle(
                                            color: CupertinoColors
                                                .secondaryLabel
                                                .resolveFrom(context),
                                          ),
                                        ),
                                      );
                                    }
                                    // ... (GridView.builder using filteredCategories) ...
                                    return GridView.builder(
                                      padding: EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).padding.bottom +
                                            16, // Adjust for safe area
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 0.9,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                          ),
                                      itemCount: filteredCategories.length,
                                      itemBuilder: (ctx, idx) {
                                        final cat = filteredCategories[idx];

                                        dev.log("${cat.fullFavIconUrl}");
                                        // Use selectedCategory from the main state
                                        final isSelected =
                                            (selectedCategory.id == cat.id);
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(
                                              modalContext,
                                            ).pop(); // Use modal's context to pop
                                            _onCategoryPicked(
                                              cat,
                                            ); // Call main state method
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 260,
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color:
                                                  isSelected
                                                      ? Theme.of(
                                                        context,
                                                      ).primaryColor.withValues(
                                                        alpha: 0.1,
                                                      ) // Use theme color
                                                      : CupertinoColors
                                                          .secondarySystemGroupedBackground
                                                          .resolveFrom(context),
                                              border:
                                                  isSelected
                                                      ? Border.all(
                                                        color:
                                                            Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                        width: 1.5,
                                                      )
                                                      : null,
                                              boxShadow: [
                                                // Subtle shadow
                                                BoxShadow(
                                                  color: CupertinoColors
                                                      .systemGrey
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: ImageView(
                                                    radius: 20,
                                                    source: ImageSource.network,

                                                    path: cat.fullFavIconUrl,
                                                    height: ScreenUtils()
                                                        .getVerticalSize(38),
                                                    width: ScreenUtils()
                                                        .getVerticalSize(38),
                                                  ),
                                                ),

                                                // Icon(
                                                //   cat.favIcon.isEmpty
                                                //       ? CupertinoIcons
                                                //           .square_grid_2x2
                                                //       : _parseIcon(cat.favIcon),
                                                //   size: 38,
                                                //   color:
                                                //       isSelected
                                                //           ? Theme.of(
                                                //             context,
                                                //           ).primaryColor
                                                //           : CupertinoColors
                                                //               .secondaryLabel
                                                //               .resolveFrom(
                                                //                 context,
                                                //               ),
                                                // ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  cat.title,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.w500,
                                                    fontSize: 14,
                                                    color:
                                                        isSelected
                                                            ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                            : CupertinoColors
                                                                .label
                                                                .resolveFrom(
                                                                  context,
                                                                ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openServiceSheet() async {
    if (selectedCategory.isEmpty || isLoadingServices) return;

    // Reset search text IF desired when opening
    // _serviceSearchController.clear(); // Optional
    // serviceSearch = '';             // Optional
    _applyServiceSearchAndSort(); // Ensure list is correct before showing

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make sheet background transparent
      builder: (modalContext) {
        // Use a different context name
        // Wrap content in StatefulBuilder for local state (dropdown)
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                // Apply decoration here
                color: CupertinoColors.systemBackground.resolveFrom(
                  context,
                ), // Use Cupertino background
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                // Add SafeArea here
                top: false, // Don't need top padding inside modal
                child:
                    isLoadingServices
                        ? const Center(child: CupertinoActivityIndicator())
                        : (errorServices != null
                            ? Center(child: Text(errorServices!))
                            : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CupertinoSearchTextField(
                                          // Use the controller
                                          controller: _serviceSearchController,
                                          placeholder: 'Search services...',
                                          // onChanged: (v) {
                                          //   // !! NO modalSetState or setState HERE !!
                                          //   serviceSearch = v;
                                          //   _applyServiceSearchAndSort();
                                          // },
                                          autocorrect: false,
                                          // suffixMode: OverlayVisibilityMode.editing,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      DropdownButton<String>(
                                        value: serviceSort,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.label
                                              .resolveFrom(context),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        items:
                                            ['A-Z', 'Z-A']
                                                .map(
                                                  (val) => DropdownMenuItem(
                                                    value: val,
                                                    child: Text('Sort: $val'),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          if (val != null &&
                                              serviceSort != val) {
                                            // Use modalSetState ONLY for dropdown state
                                            modalSetState(() {
                                              serviceSort = val;
                                            });
                                            _applyServiceSearchAndSort();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                // const SizedBox(height: 10), // Remove extra space
                                Expanded(
                                  // ValueListenableBuilder listens for service list updates
                                  child: ValueListenableBuilder<void>(
                                    valueListenable: _serviceFilterNotifier,
                                    builder: (_, __, ___) {
                                      if (filteredServices.isEmpty) {
                                        return Center(
                                          child: Text(
                                            serviceSearch.isEmpty
                                                ? "No services found for this category."
                                                : "No results for \"$serviceSearch\"",
                                            style: TextStyle(
                                              color: CupertinoColors
                                                  .secondaryLabel
                                                  .resolveFrom(context),
                                            ),
                                          ),
                                        );
                                      }
                                      // GridView using filteredServices
                                      return GridView.builder(
                                        padding: EdgeInsets.only(
                                          top: 16,
                                          left: 16,
                                          right: 16,
                                          // Adjust bottom padding for potential Done button and safe area
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).padding.bottom +
                                              80, // Increased padding
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio:
                                                  0.85, // Adjust ratio slightly if needed
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                            ),
                                        itemCount: filteredServices.length,
                                        itemBuilder: (ctx, idx) {
                                          final svc = filteredServices[idx];
                                          // Use selectedServices from the main state
                                          final isSelected =
                                              selectedServices.id == svc.id;
                                          return GestureDetector(
                                            onTap: () {
                                              // Don't pop here if you want multi-select or just confirmation
                                              // Update the main state's selected service
                                              // Need main widget's setState if the selection should persist visually *within the modal*
                                              // If single select, just update and pop
                                              setState(() {
                                                selectedServices = svc;
                                              });
                                              widget.onServicesSelected(
                                                svc,
                                              ); // Notify parent
                                              Navigator.of(
                                                modalContext,
                                              ).pop(); // Pop after selection for single-select
                                              // If multi-select, you'd update a list in main state and possibly call modalSetState here
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 260,
                                              ),
                                              padding: const EdgeInsets.all(
                                                8,
                                              ), // Adjust padding
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                color:
                                                    isSelected
                                                        ? context
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            )
                                                        : CupertinoColors
                                                            .secondarySystemGroupedBackground
                                                            .resolveFrom(
                                                              context,
                                                            ),
                                                border:
                                                    isSelected
                                                        ? Border.all(
                                                          color:
                                                              Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                          width: 1.5,
                                                        )
                                                        : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: CupertinoColors
                                                        .systemGrey
                                                        .withOpacity(0.1),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    // Use a placeholder or handle image errors
                                                    child: ImageView(
                                                      // Ensure ImageView handles errors/loading
                                                      source:
                                                          ImageSource.network,
                                                      path: svc.fullImageUrl,
                                                      height: 50, // Adjust size
                                                      width: 70, // Adjust size
                                                      fit: BoxFit.cover,
                                                      radius:
                                                          12, // Match ClipRRect
                                                      // placeholder: Icon(CupertinoIcons.photo), // Example placeholder
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    svc.serviceName,
                                                    textAlign: TextAlign.center,
                                                    maxLines:
                                                        2, // Allow two lines
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                      fontSize:
                                                          13, // Slightly smaller font
                                                      color:
                                                          isSelected
                                                              ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                              : CupertinoColors
                                                                  .label
                                                                  .resolveFrom(
                                                                    context,
                                                                  ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // // Optional: Remove "Done" button if selection happens on tap
                                // Padding(
                                //   padding: EdgeInsets.only(
                                //     bottom: MediaQuery.of(context).padding.bottom + 10, // Adjust padding for safe area
                                //     left: 16, right: 16, top: 10
                                //   ),
                                //   child: CupertinoButton.filled(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 36,
                                //       vertical: 16, // Adjust padding
                                //     ),
                                //     borderRadius: BorderRadius.circular(16),
                                //     child: const Text("Done"),
                                //     onPressed: () {
                                //       // Already notified parent on tap, just pop
                                //       Navigator.of(modalContext).pop();
                                //     },
                                //   ),
                                // ),
                                // const SizedBox(height: 10), // Remove if button removed
                              ],
                            )),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(CategoryAndServicesStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool categoryChanged =
        widget.selectedCategoryId != oldWidget.selectedCategoryId;
    bool serviceChanged =
        widget.selectedServiceId != oldWidget.selectedServiceId;

    // Handle category change
    if (categoryChanged) {
      dev.log(
        "didUpdateWidget: Category changed from ${oldWidget.selectedCategoryId} to ${widget.selectedCategoryId}",
      );
      if (widget.selectedCategoryId == null) {
        // Category deselected externally
        _handleClear(); // Reset everything
      } else {
        // Category selected/changed externally
        // Ensure categories are loaded before attempting selection
        if (allCategories.isNotEmpty) {
          _fetchAndSelectCategory(widget.selectedCategoryId!);
        } else {
          // Categories might not be loaded yet, _fetchCategories result or initState callback will handle it.
          dev.log(
            "didUpdateWidget: Categories not yet loaded, deferring category selection.",
          );
        }
      }
    }

    // Handle service change AFTER category is potentially updated
    if (serviceChanged && !categoryChanged) {
      // Only handle service change if category didn't change in the same update
      dev.log(
        "didUpdateWidget: Service changed from ${oldWidget.selectedServiceId} to ${widget.selectedServiceId}",
      );
      if (widget.selectedServiceId == null) {
        // Service deselected externally
        if (!selectedServices.isEmpty) {
          // Avoid unnecessary state update if already empty
          setState(() {
            selectedServices = ServiceModel.empty();
            widget.onServicesSelected(null); // Ensure parent knows
          });
        }
      } else {
        // Service selected/changed externally
        // Ensure services for the *current* selectedCategory are loaded/available
        _selectInitialService(widget.selectedServiceId!);
      }
    } else if (serviceChanged && categoryChanged) {
      // Service change happened alongside category change.
      // The selection logic inside _onCategoryPicked or _fetchServicesForCategory
      // should handle the initial service selection based on the new widget.selectedServiceId
      dev.log(
        "didUpdateWidget: Service changed concurrently with category. Selection handled by category change logic.",
      );
    }
  }

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      // Use toLowerCase for robustness
      case 'salon':
        return CupertinoIcons.scissors;
      case 'spa':
        return CupertinoIcons
            .flame; // Or another suitable icon like thermometer or drop
      case 'gym':
        return CupertinoIcons.sportscourt;
      // Add more cases as needed
      default:
        return CupertinoIcons.square_grid_2x2; // Default icon
    }
  }

  void _handleClear() {
    // Clear controllers first
    _categorySearchController.clear();
    _serviceSearchController.clear();

    setState(() {
      selectedCategory = CategoryModel.empty();
      selectedServices = ServiceModel.empty();
      allServicesForCategory = [];
      // Don't reset allCategories, just the filters/selection
      filteredCategories = List.from(allCategories); // Reset filter
      filteredServices = [];
      categorySearch = '';
      serviceSearch = '';
      // Reset sort? Optional, depends on desired behavior
      // categorySort = 'A-Z';
      // serviceSort = 'A-Z';

      isLoadingServices = false; // Ensure loading indicators are off
      errorServices = null;
    });

    // Notify listeners to clear lists in modals if they are open
    _categoryFilterNotifier.value = null;
    _serviceFilterNotifier.value = null;

    // Notify parent widget
    widget.onCategorySelected(null);
    widget.onServicesSelected(null);
    widget.resetForm(); // Call the provided reset callback
  }

  // Helper to build the selection card UI consistently
  Widget _buildSelectionCard({
    required String titleWhenSelected,
    required String titleWhenNotSelected,
    required IconData icon,
    required bool isSelected,
    required bool isCategory, // To determine which state vars to use
    required VoidCallback? onTap,
    required Color selectedColor,
  }) {
    final bool isLoading = isCategory ? isLoadingCategories : isLoadingServices;
    final bool isDisabled =
        isCategory
            ? isLoadingCategories
            : (selectedCategory.isEmpty || isLoadingServices);
    final Color effectiveColor = isSelected ? selectedColor : Colors.grey;
    final String text = isSelected ? titleWhenSelected : titleWhenNotSelected;
    final FontWeight fontWeight =
        isSelected ? FontWeight.bold : FontWeight.normal;

    return GestureDetector(
      onTap:
          isDisabled
              ? null
              : onTap, // Disable tap when loading or category not selected for services
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white, // Use Material for ink splash if needed
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ), // Consistent padding
          decoration: BoxDecoration(
            color: Colors.white, // Ensure background color
            borderRadius: BorderRadius.circular(12), // Match Material radius
            border: Border.all(
              color:
                  isSelected
                      ? selectedColor.withValues(alpha: 0.5)
                      : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Opacity(
            // Dim the card slightly if disabled
            opacity: isDisabled && !isLoading ? 0.6 : 1.0,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: effectiveColor,
                  size: 24,
                ), // Consistent icon size
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: effectiveColor,
                      fontWeight: fontWeight,
                      fontSize: 16,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Prevent long text overflow
                  ),
                ),
                if (isLoading)
                  const CupertinoActivityIndicator(
                    radius: 10,
                  ) // Smaller indicator
                else if (!isDisabled) // Only show chevron if tappable
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the validation message
  Widget _buildValidationMessage(String message) {
    return Material(
      // Wrap in Material for consistent text styling
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12.5,
          ), // Slightly smaller
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor; // Use theme color

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8), // Add space if needed above
          // Category Selection Card
          _buildSelectionCard(
            titleWhenSelected: selectedCategory.title,
            titleWhenNotSelected: 'Select Category',
            icon:
                selectedCategory.isEmpty
                    ? CupertinoIcons.square_grid_2x2
                    : _parseIcon(selectedCategory.favIcon),
            isSelected: !selectedCategory.isEmpty,
            isCategory: true,
            onTap: _openCategorySheet,
            selectedColor: primaryColor,
          ),
          // Category Validation (Example - integrate with Form validator if preferred)
          if (selectedCategory.isEmpty)
            _buildValidationMessage('Please select a category'),

          const SizedBox(height: 18),

          // Service Selection Card
          _buildSelectionCard(
            titleWhenSelected: selectedServices.serviceName,
            titleWhenNotSelected: 'Select Service',
            icon: CupertinoIcons.square_list, // Or a more relevant icon
            isSelected: !selectedServices.isEmpty,
            isCategory: false,
            onTap: _openServiceSheet,
            selectedColor: primaryColor,
          ),
          // Service Validation (Example)
          // Only show if category IS selected but service is NOT
          if (!selectedCategory.isEmpty && selectedServices.isEmpty)
            _buildValidationMessage('Please select a service'),

          const SizedBox(height: 24), // Increased space before clear button
          // Clear Button - Align right
          if (!selectedCategory.isEmpty ||
              !selectedServices
                  .isEmpty) // Only show if there's something to clear
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: _handleClear,
                child: const Text(
                  'Clear selection',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                  ), // Slightly smaller text
                ),
              ),
            ),
        ],
      ),
    );
  }
}
