<?php
namespace App\Helpers;

class WordHelper
{

    public function permutationofString($string)
    {
        $data_array = [];

        function permute($str, $l, $r, &$perms)
        {
            if ($l == $r) {
                $perms[] = $str;
            } else {
                for ($i = $l; $i <= $r; $i ++) {
                    $str = swapPositions($str, $l, $i);
                    permute($str, $l + 1, $r, $perms);
                    $str = swapPositions($str, $l, $i); // backtrack
                }
            }
        }

        function swapPositions($str, $i, $j)
        {
            $temp = $str[$i];
            $str[$i] = $str[$j];
            $str[$j] = $temp;
            return $str;
        }

        $perms = [];
        permute($string, 0, strlen($string) - 1, $perms);

        // Ensure unique permutations only, just in case
        $perms = array_unique($perms);

        foreach ($perms as $perm) {
            $data_array[] = $perm;
        }
        return $data_array;
    }
}