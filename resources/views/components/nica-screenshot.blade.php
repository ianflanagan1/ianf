@props(['image', 'title', 'paragraphs'])

<div>
    <a href="images/nica/{{ $image }}.jpeg"><img src="images/nica/{{ $image }}.jpeg" ></a>
    <div>
        <h3>{{ $title }} </h3>
        @foreach ($paragraphs as $paragraph)
            <p>{{ $paragraph }}</p>
        @endforeach
    </div>
</div>