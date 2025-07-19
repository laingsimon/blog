function setEditableContent(name, value) {
    if (!value) {
        return;
    }

    const element = document.querySelector(`[name="${name}"]`);
    if (!element) {
        return;
    }

    element.textContent = value;
}

function getParam(name) {
    const query = new URLSearchParams(document.location.search);
    return query.get(name);
}

function onLoad() {
    setEditableContent('phone', getParam('phone'));
    setEditableContent('email', getParam('email'));

    const dontationsOnly = !!getParam('donations-only');
    if (dontationsOnly) {
        document.body.className += ' donations-only';
    }
}

window.addEventListener('load', onLoad);