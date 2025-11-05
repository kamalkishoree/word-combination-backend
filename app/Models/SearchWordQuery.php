<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SearchWordQuery extends Model
{
    use HasFactory;
    
    protected $fillable = [
        "search_word" ,
        "word_length",
        "permutation",
        "words_combinations_id" 
    ];
    public function wordCombination()
    {
        return $this->hasOne(wordsCombination::class, 'id', 'words_combinations_id');
    }
    
    
}
