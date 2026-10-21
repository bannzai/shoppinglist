package com.bannzai.shoppinglist

import java.io.File
import javax.xml.parsers.DocumentBuilderFactory
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.w3c.dom.Element

class ShoppingListWidgetToggleReceiverTest {
    private val androidNamespace = "http://schemas.android.com/apk/res/android"

    /** src/main/AndroidManifest.xml の receiver 要素を android:name をキーにして返す。 */
    private fun manifestReceivers(): Map<String, Element> {
        val documentBuilderFactory = DocumentBuilderFactory.newInstance().apply { isNamespaceAware = true }
        val document = documentBuilderFactory.newDocumentBuilder().parse(File("src/main/AndroidManifest.xml"))
        val receiverNodes = document.getElementsByTagName("receiver")
        return (0 until receiverNodes.length)
            .map { receiverNodes.item(it) as Element }
            .associateBy { it.getAttributeNS(androidNamespace, "name") }
    }

    @Test
    fun toggleReceiverIsNotExported() {
        val toggleReceiver = manifestReceivers()[".ShoppingListWidgetToggleReceiver"]
        assertNotNull(toggleReceiver)
        assertEquals("false", toggleReceiver!!.getAttributeNS(androidNamespace, "exported"))
        assertEquals(0, toggleReceiver.getElementsByTagName("intent-filter").length)
    }

    @Test
    fun exportedWidgetProviderDoesNotHandleToggleAction() {
        val widgetProvider = manifestReceivers()[".ShoppingListWidgetProvider"]
        assertNotNull(widgetProvider)
        val actionNodes = widgetProvider!!.getElementsByTagName("action")
        val actionNames = (0 until actionNodes.length)
            .map { (actionNodes.item(it) as Element).getAttributeNS(androidNamespace, "name") }
        assertFalse(actionNames.contains(ShoppingListWidgetToggleReceiver.ACTION_TOGGLE_ITEM))
    }

    @Test
    fun cachedItemIsAccepted() {
        val itemsJson = """[{"id":"item1","message":"牛乳","status":"unchecked"},{"id":"item2","message":"卵","status":"checked"}]"""
        assertTrue(isWidgetCachedItem(itemsJson = itemsJson, itemID = "item2"))
    }

    @Test
    fun itemOutsideCacheIsRejected() {
        val itemsJson = """[{"id":"item1","message":"牛乳","status":"unchecked"}]"""
        assertFalse(isWidgetCachedItem(itemsJson = itemsJson, itemID = "other"))
        assertFalse(isWidgetCachedItem(itemsJson = "[]", itemID = "item1"))
        assertFalse(isWidgetCachedItem(itemsJson = "not json", itemID = "item1"))
    }
}
