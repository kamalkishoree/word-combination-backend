<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('search_word_queries', function (Blueprint $table) {
            $table->id();
            $table->longText('search_word')->unique();
            $table->bigInteger('word_length');
            $table->longText('permutation');
            $table->bigInteger('words_combinations_id');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('search_word_queries');
    }
};
