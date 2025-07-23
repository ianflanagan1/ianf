<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/nica', function () {
    return view('nica');
});
Route::get('/api-video', function () {
    return redirect()->away('https://youtu.be/G7Nug1Mr9VE', 301);
});
