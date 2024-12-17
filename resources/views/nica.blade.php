<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>NICA</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Styles / Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans antialiased">
        <div id="holder">
            <h1>Service Account</h1>
            <div class="screenshots">
                <x-nica-screenshot :title="'Service Account'" :image="'service-account3'" :paragraphs="[
                    'Feed of articles sent to subscribed users with notifications',
                ]" />
                <x-nica-screenshot :title="'Service Account: Menu 1'" :image="'service-account3-menu1'" :paragraphs="[
                    'Links to the offical NICA website and a service account article titled \'About Nica\'',
                ]" />
                <x-nica-screenshot :title="'Service Account: Menu 2'" :image="'service-account3-menu2'" :paragraphs="[
                    'Link to the NICA Questionnaires Mini Program (集思社问卷), and service account articles titled \'Become a NICA member\' and \'How to take part in events\'',
                ]" />
                <x-nica-screenshot :title="'Article Example 1'" :image="'article1'" :paragraphs="[
                    'An article published by the service account',
                ]" />
                <x-nica-screenshot :title="'Article Example 2'" :image="'article2'" :paragraphs="[
                    'An article published by the service account',
                ]" />
                <x-nica-screenshot :title="'Article Example 3'" :image="'article3'" :paragraphs="[
                    'An article published by the service account',
                ]" />
            </div>
            <h1>Mini Program</h1>
            <div class="screenshots">
                <x-nica-screenshot :title="'Mini Programs Entry point'" :image="'entry-mp'" :paragraphs="[
                    'Accessed by swiping down on the stardard \'Chats\' view of WeChat',
                    'The top-left icon is the NICA Mini Program (集思社问卷)',
                ]" />
                <x-nica-screenshot :title="'Index'" :image="'index'" :paragraphs="[
                    'Auto-rotating carousel header with posters as links to service account articles on various topics',
                    'Scrollable list of projects: questionnairres, product usage diaries, events',
                    'Bottom menu with the options: \'Home\', \'About us\' and \'Profile\'',
                ]" />
                <x-nica-screenshot :title="'Loading'" :image="'loading'" :paragraphs="[
                    'Loading spinner while API responds',
                ]" />
                <x-nica-screenshot :title="'Questonnaire Summary'" :image="'questionnaire-show'" :paragraphs="[
                    'Summary page for a particular questionnaire listing age restriction, expected time requirement, closing date, description, and financial reward',
                    'Title bar was removed to boost the aesthetic appeal of the header image',
                ]" />

                <x-nica-screenshot :title="'Login'" :image="'login'" :paragraphs="[
                    'Login is required to sign-up to any questionnaire',
                    'For legal compliance, the user must agree to the privacy policy and a special user agreement that permits thei inputted data to be exported overseas',
                ]" />
                <x-nica-screenshot :title="'Login: Get phone number'" :image="'login-get-phone'" :paragraphs="[
                    'Select phone number to use from numbers held by WeChat',
                ]" />
                <x-nica-screenshot :title="'Login: Privacy Policy'" :image="'privacy-policy'" :paragraphs="[]" />
                <x-nica-screenshot :title="'Login: User Agreement'" :image="'user-agreement'" :paragraphs="[]" />

                <x-nica-screenshot :title="'Input: Checkboxes'" :image="'input-checkbox-top'" :paragraphs="[
                    'Input type for pre-defined multiple-select options',
                    'Minimum checks defined when creating the questionnaire',
                    'Questionnaire progress indicator at the top',
                ]" />
                <x-nica-screenshot :title="'Input: Checkboxes (bottom)'" :image="'input-checkbox-bottom'" :paragraphs="[
                    'Progress buttons access by scrolling, to encouage consideration of all options before progressing',
                ]" />
                <x-nica-screenshot :title="'Input: Radio'" :image="'input-radio'" :paragraphs="[
                    'Input type for pre-defined single-select options',
                ]" />
                <x-nica-screenshot :title="'Input: Integer'" :image="'input-integer'" :paragraphs="[
                    'For numerical input',
                ]" />
                <x-nica-screenshot :title="'Input: Textarea'" :image="'input-textarea'" :paragraphs="[
                    'For text input',
                ]" />
                <x-nica-screenshot :title="'Input: Images'" :image="'input-images-choose'" :paragraphs="[
                    'Select images to uploaded from device, or from the camera app directly',
                ]" />
                <x-nica-screenshot :title="'Input: Images (selected)'" :image="'input-images'" :paragraphs="[
                    'Display of uploaded images with the option to reorder, delete, or continue uploading',
                ]" />
                <x-nica-screenshot :title="'Input: Audio'" :image="'input-audio'" :paragraphs="[
                    'Button to long press and record an audio answer. This is converted to text for the NICA admins to process',
                ]" />
                <x-nica-screenshot :title="'Input: Audio (recording)'" :image="'input-audio-recording'" :paragraphs="[
                    'Animation to indicate recording is in progress',
                ]" />
                <x-nica-screenshot :title="'Input: Audio (recorded)'" :image="'input-audio-after'" :paragraphs="[
                    'Audio files with the option to playback, delete, or continue recording',
                    'Some questions (like this one) have an option to switch to keyboard input if preferred'
                ]" />
                <x-nica-screenshot :title="'Completed'" :image="'questionnaire-completed'" :paragraphs="[
                    'Completion screen with option to return',
                ]" />

                <x-nica-screenshot :title="'Profile'" :image="'profile'" :paragraphs="[
                    'Profile page with login button, \'My questionnaires\', \'My balance\' and FAQs leading to service account articles',
                    'If logged in, the login button is replaced with name and profile picture, which lead to account settings with log out and delete account options',
                ]" />
                <x-nica-screenshot :title="'My Questionnaires'" :image="'my-questionnaires'" :paragraphs="[
                    'A list of questionnaires the user and signed-up for, with filter options: \'All\', \'Applied\', \'In progress\', and \'Completed\'',
                ]" />
            </div>
        </div>
    </body>
</html>
