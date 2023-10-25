import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:healthy_cook/components/recipe_detail_algolia.dart';

class SearchAlgolia extends StatefulWidget {
  const SearchAlgolia({Key? key}) : super(key: key);

  @override
  State<SearchAlgolia> createState() => _SearchAlgoliaState();
}

class _SearchAlgoliaState extends State<SearchAlgolia> {
  final hitsSearcher = HitsSearcher(
    apiKey: '8edf391b71066e8d6a2db8ee78a91c76',
    applicationID: 'Q5SEP4O5F4',
    indexName: 'healthycook',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (input) => hitsSearcher.query(input),
            decoration: const InputDecoration(
              hintText: 'Digite sua busca',
            ),
          ),
        ),
        StreamBuilder<SearchResponse>(
          stream: hitsSearcher.responses,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              final response = snapshot.data;
              final hits = response?.hits.toList() ?? [];

              if (hits.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Não há resultados para sua pesquisa',
                    ),
                  ),
                );
              }

              hits.sort(
                  (a, b) => b['likes'].length.compareTo(a['likes'].length));
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hits.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecipeDetailAlgolia(
                                recipeDocumentId: hits[i]['objectID'],
                              )),
                    )
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(hits[i]['urlImage']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black.withOpacity(0.5),
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  hits[i]['title'],
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            '${hits[i]['likes'].length.toString()} ${hits[i]['likes'] == 1 ? "curtida" : "curtidas"}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }
}
