<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SearchWordQuery;
use App\Models\wordsCombination;
use App\Helpers\WordHelper;
use App\Services\WordRequestService;

class WordCombinationController extends Controller
{

    // controller
    public function wordCollection(Request $request, WordRequestService $wordRequest)
    {
        $request->validate([
            'name' => 'required'
        ]);
        $Exist_SearchWordQuery = SearchWordQuery::whereRaw("FIND_IN_SET(?, REPLACE(permutation, ' ', ''))", [
            $request->name
        ])->where('word_length', strlen($request->name))->first();

        if ($Exist_SearchWordQuery) {
            $exist_search_word = $Exist_SearchWordQuery;
            $exist_wordCombination = $exist_search_word->wordCombination;
            $response = [
                'search_word' => $request->name,
                'word_combination' => explode(', ', $exist_wordCombination->result_words),
                'status' => 200
            ];
            return response()->json($response);
        }

        $combination = (new WordHelper())->permutationofString($request->name);
        try {
            $result = $wordRequest->wordRequest($request->name);
            if (! empty($result)) {
                $word_combination = wordsCombination::create([
                    "result_words" => implode(', ', $result)
                ]);
                if ($word_combination) {
                    $search_word_data = [
                        "search_word" => $request->name,
                        "word_length" => strlen($request->name),
                        "permutation" => implode(', ', $combination),
                        "words_combinations_id" => $word_combination->id
                    ];
                    $search_word = SearchWordQuery::create($search_word_data);
                    if ($search_word) {
                        $response = [
                            'search_word' => $request->name,
                            'word_combination' => explode(',', $word_combination->result_words),
                            'status' => 200
                        ];
                        return response()->json($response);
                    }
                }
            }
        } catch (\Exception $e) {
            \Log::error($e->getMessage());
            return response()->json([
                'message' => $e->getMessage()
            ], 500);
        }
    }
}