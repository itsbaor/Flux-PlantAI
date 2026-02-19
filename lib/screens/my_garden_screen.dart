import 'package:flutter/material.dart';
import 'dart:io';
import '../models/plant.dart';
import '../services/garden_service.dart';
import '../widgets/plant_grid_card.dart';
import '../widgets/plant_list_card.dart';
import '../widgets/app_background.dart';
import 'scan_screen.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen>
    with SingleTickerProviderStateMixin {
  String selectedCategory = 'ALL';
  bool isGridView = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final GardenService _gardenService = GardenService();
  List<Plant> _plants = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    try {
      final plants = await _gardenService.getAllPlants();
      if (mounted) {
        setState(() {
          _plants = plants;
          _isLoading = false;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Plant> get filteredPlants {
    var result = _plants;

    if (selectedCategory != 'ALL') {
      result = result.where((p) => p.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((p) {
        return p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.scientificName.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  int get _healthyPlantsCount {
    return _plants
        .where((p) =>
            p.healthStatus == 'excellent' || p.healthStatus == 'good')
        .length;
  }

  int get _needsAttentionCount {
    return _plants
        .where((p) =>
            p.healthStatus == 'fair' || p.healthStatus == 'poor')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Stats Cards
            if (!_isLoading && _plants.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildStatsSection(),
              ),
            // Search & Filter
            SliverToBoxAdapter(
              child: _buildSearchAndFilter(),
            ),
            // Category Tabs
            SliverToBoxAdapter(
              child: _buildCategoryTabs(),
            ),
            // View Toggle & Count
            SliverToBoxAdapter(
              child: _buildViewToggle(),
            ),
            // Plants Grid/List
            _isLoading
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoadingState(),
                  )
                : filteredPlants.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    : _buildPlantsSliver(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Garden',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _plants.isEmpty
                        ? 'Start your plant collection'
                        : '${_plants.length} plants in your collection',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Refresh button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadPlants,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xFF4CAF50),
                label: 'Healthy',
                value: '$_healthyPlantsCount',
                gradient: [
                  const Color(0xFF4CAF50).withOpacity(0.2),
                  const Color(0xFF4CAF50).withOpacity(0.05),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFFF9800),
                label: 'Needs Care',
                value: '$_needsAttentionCount',
                gradient: [
                  const Color(0xFFFF9800).withOpacity(0.2),
                  const Color(0xFFFF9800).withOpacity(0.05),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF2196F3),
                label: 'Indoor',
                value: '${_plants.where((p) => p.category == 'Indoor').length}',
                gradient: [
                  const Color(0xFF2196F3).withOpacity(0.2),
                  const Color(0xFF2196F3).withOpacity(0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search plants...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          _buildCategoryTab('ALL', 'All', Icons.apps_rounded),
          const SizedBox(width: 10),
          _buildCategoryTab('Indoor', 'Indoor', Icons.home_rounded),
          const SizedBox(width: 10),
          _buildCategoryTab('Outdoor', 'Outdoor', Icons.park_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String value, String label, IconData icon) {
    final isSelected = selectedCategory == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF90EE90), Color(0xFF5DBB63)],
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF0D2818) : Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? const Color(0xFF0D2818) : Colors.grey[400],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredPlants.length} ${filteredPlants.length == 1 ? 'plant' : 'plants'}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: isGridView,
                  onTap: () => setState(() => isGridView = true),
                ),
                const SizedBox(width: 4),
                _buildViewToggleButton(
                  icon: Icons.view_list_rounded,
                  isSelected: !isGridView,
                  onTap: () => setState(() => isGridView = false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF90EE90) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF0D2818) : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF90EE90).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF90EE90),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your garden...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF90EE90).withOpacity(0.2),
                    const Color(0xFF5DBB63).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF90EE90).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 56,
                color: Color(0xFF90EE90),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.isNotEmpty ? 'No plants found' : 'Your garden awaits',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Scan your first plant to start building\nyour personal plant collection',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF90EE90), Color(0xFF5DBB63)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF90EE90).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            color: Color(0xFF0D2818),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Scan a Plant',
                            style: TextStyle(
                              color: Color(0xFF0D2818),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlantsSliver() {
    if (isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: PlantGridCard(
                  plant: filteredPlants[index],
                  onTap: () => _navigateToDetail(filteredPlants[index]),
                ),
              );
            },
            childCount: filteredPlants.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: PlantListCard(
                  plant: filteredPlants[index],
                  onTap: () => _navigateToDetail(filteredPlants[index]),
                ),
              );
            },
            childCount: filteredPlants.length,
          ),
        ),
      );
    }
  }

  void _navigateToDetail(Plant plant) {
    Navigator.pushNamed(
      context,
      '/plant-detail',
      arguments: plant,
    ).then((_) {
      _loadPlants();
    });
  }
}
