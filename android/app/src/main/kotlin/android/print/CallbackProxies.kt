package android.print

class LayoutResultCallbackProxy(
    private val onFinished: (PrintDocumentInfo?, Boolean) -> Unit,
    private val onFailed: (CharSequence?) -> Unit,
    private val onCancelled: () -> Unit
) : PrintDocumentAdapter.LayoutResultCallback() {
    override fun onLayoutFinished(info: PrintDocumentInfo?, changed: Boolean) {
        onFinished(info, changed)
    }

    override fun onLayoutFailed(error: CharSequence?) {
        onFailed(error)
    }

    override fun onLayoutCancelled() {
        onCancelled()
    }
}

class WriteResultCallbackProxy(
    private val onFinished: (Array<PageRange>) -> Unit,
    private val onFailed: (CharSequence?) -> Unit,
    private val onCancelled: () -> Unit
) : PrintDocumentAdapter.WriteResultCallback() {
    override fun onWriteFinished(pages: Array<PageRange>) {
        onFinished(pages)
    }

    override fun onWriteFailed(error: CharSequence?) {
        onFailed(error)
    }

    override fun onWriteCancelled() {
        onCancelled()
    }
}
