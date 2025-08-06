// app/assets/javascripts/component_edit.js
// Wait for jQuery to be available
(function() {
    function initComponentEdit() {
        if (typeof $ === 'undefined') {
            // jQuery not ready yet, try again in 100ms
            setTimeout(initComponentEdit, 100);
            return;
        }

        console.log('Component edit script loaded with jQuery');

        $(document).ready(function() {
            console.log('jQuery document ready');

            // Handle edit button clicks using data attributes
            $(document).on('click', '.edit-component-btn', function(e) {
                console.log('Edit button clicked!');
                e.preventDefault();

                var themeId = $(this).data('theme-id');
                var componentId = $(this).data('component-id');

                console.log('Theme ID:', themeId, 'Component ID:', componentId);

                if (themeId && componentId) {
                    loadEditForm(themeId, componentId);
                } else {
                    console.log('Missing theme or component ID');
                }
            });

            // Fallback: Handle edit button clicks using class parsing
            $(document).on('click', '.component-section button:not(.edit-component-btn)', function(e) {
                console.log('Fallback: Edit button clicked!');
                e.preventDefault();

                var componentSection = $(this).closest('.component-section');
                var classes = componentSection.attr('class').split(/\s+/);
                var themeComponentClass = classes.find(cls => cls.match(/theme-\d+-component-\d+/));

                if (themeComponentClass) {
                    var matches = themeComponentClass.match(/theme-(\d+)-component-(\d+)/);
                    var themeId = matches[1];
                    var componentId = matches[2];

                    console.log('Theme ID:', themeId, 'Component ID:', componentId);
                    loadEditForm(themeId, componentId);
                }
            });

            // Handle form submission
            $(document).on('submit.component-edit', '#component-edit-form', function(e) {
                console.log('Form submitted');
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();

                var form = $(this);
                var submitBtn = form.find('input[type="submit"]');

                // Check if already submitting to prevent double submission
                if (submitBtn.prop('disabled') || form.hasClass('submitting')) {
                    console.log('Form already submitting, ignoring duplicate submission');
                    return false;
                }

                // Mark form as submitting
                form.addClass('submitting');
                submitBtn.prop('disabled', true).val('Updating...');

                console.log('Starting AJAX request to:', form.attr('action'));

                $.ajax({
                    url: form.attr('action'),
                    method: 'PATCH',
                    data: form.serialize(),
                    dataType: 'json',
                    timeout: 10000, // 10 second timeout
                    success: function(response) {
                        console.log('Update response:', response);
                        if (response.status === 'success') {
                            showNotification(response.message, 'success');

                            // Update the components partial with the new HTML
                            if (response.updated_html) {
                                var componentsContainer = $('.components-container');
                                if (componentsContainer.length) {
                                    componentsContainer.html(response.updated_html);
                                    console.log('Components partial reloaded with updated content');
                                } else {
                                    console.warn('Components container not found');
                                }
                            }

                            // Close the form after successful update
                            setTimeout(function() {
                                closeEditForm();
                            }, 1000);

                        } else {
                            showNotification(response.message, 'error');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.log('Update error:', xhr, status, error);
                        var errorMsg = 'An error occurred while updating the component.';
                        if (xhr.responseJSON && xhr.responseJSON.message) {
                            errorMsg = xhr.responseJSON.message;
                        }
                        showNotification(errorMsg, 'error');
                    },
                    complete: function(xhr, status) {
                        console.log('AJAX request complete with status:', status);
                        // Remove submitting state
                        form.removeClass('submitting');
                        submitBtn.prop('disabled', false).val('Update Component');
                    }
                });

                return false;
            });
        });
    }

    // Start trying to initialize
    initComponentEdit();

    // Also try when the window loads
    window.addEventListener('load', initComponentEdit);
})();

function loadEditForm(themeId, componentId) {
    console.log('Loading edit form for theme:', themeId, 'component:', componentId);

    const currentPath = window.location.pathname;
    const pathParts = currentPath.split('/');
    const pageSlug = pathParts[pathParts.length - 1];

    console.log('Current path:', currentPath);
    console.log('Page slug:', pageSlug);

    const formPopup = document.querySelector('.form-popup');
    const backdrop = document.querySelector('.form-backdrop');

    // Show loading state
    formPopup.innerHTML = '<div class="flex items-center justify-center h-64"><div class="text-gray-500">Loading...</div></div>';

    // Slide in the form popup
    formPopup.classList.add('active');
    backdrop.classList.add('active');

    const url = '/manage/website/editor/' + pageSlug + '/' + themeId + '/' + componentId + '/edit_form';
    console.log('AJAX URL:', url);

    fetch(url, {
        method: 'GET',
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
    })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(html => {
            console.log('Edit form loaded successfully');
            formPopup.innerHTML = html;
        })
        .catch(error => {
            console.log('Fetch error:', error);
            formPopup.innerHTML = '<div class="p-4"><div class="text-red-500">Failed to load edit form: ' + error.message + '</div></div>';
            showNotification('Failed to load edit form', 'error');
        });
}

function closeEditForm() {
    console.log('Closing edit form');
    const formPopup = document.querySelector('.form-popup');
    const backdrop = document.querySelector('.form-backdrop');

    // Slide out the form popup
    formPopup.classList.remove('active');
    backdrop.classList.remove('active');

    // Clear content after animation completes
    setTimeout(() => {
        if (!formPopup.classList.contains('active')) {
            formPopup.innerHTML = '';
        }
    }, 300); // Match the transition duration
}

// Close form when clicking outside (on backdrop)
document.addEventListener('click', function(e) {
    if (e.target.matches('.form-backdrop')) {
        closeEditForm();
    }
});

// Close form with Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const formPopup = document.querySelector('.form-popup');
        if (formPopup.classList.contains('active')) {
            closeEditForm();
        }
    }
});

function showNotification(message, type) {
    console.log('Showing notification:', message, type);
    if (typeof $ !== 'undefined') {
        var bgColor = type === 'success' ? 'bg-green-500' : 'bg-red-500';
        var notification = $(`
      <div class="fixed top-4 right-4 ${bgColor} text-white px-6 py-3 rounded-lg shadow-lg z-50 notification">
        ${message}
      </div>
    `);

        $('body').append(notification);
        notification.fadeIn(300).delay(3000).fadeOut(300, function() {
            $(this).remove();
        });
    }
}