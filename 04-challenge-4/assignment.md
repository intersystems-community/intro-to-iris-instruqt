---
slug: challenge-4
id: 594o3smbtq8q
type: challenge
title: Integration Layer
notes:
- type: text
  contents: |
    # Integration Layer
    At the core of InterSystems IRIS is a powerful interoperability engine, designed to connect systems, applications, and data sources with ease.

    InterSystems IRIS provides built-in support for integrating across a wide range of protocols and formats, including industry-specific and healthcare data formats. This enables organizations to exchange and transform data across systems without relying on additional integration platforms.

    Because integration runs directly within the InterSystems IRIS platform, data flows can be managed, monitored, and processed in real time. Transactional locking allows multiple applications to read, write, and modify data simultaneously without conflicts, maintaining reliability and consistency, even in complex, high-volume environments.
tabs:
- id: vl33es18zc72
  title: Shop
  type: service
  hostname: iris
  path: /csp/user/order.html
  port: 52773
- id: hezenzl4t4re
  title: IRIS
  type: service
  hostname: iris
  path: /ui/interop/interop-editor/index.html?$NAMESPACE=USER&$PRODUCTION=HoleFoods.Interop.Production
  port: 52773
  protocol: http
- id: myvbqfctfiz9
  title: Mail
  type: service
  hostname: iris
  port: 8025
difficulty: ""
enhanced_loading: null
---
HoleFoods is opening an online shop! We just restocked the Gummy Rings, so let's make sure we sell some of these.

We've already created a web page to send orders, a REST API to receive data from the web page, and an InterSystems IRIS interoperability production to ensure the data can be traced and routed through the right processes.

Let's start by submitting an order.

**In the [Shop](tab-0), find the gummy rings, choose a delivery location and click `Place Order`.**

We get redirected to a thank-you page — seems pretty standard. Let's take a look at the back end.

**Open the [IRIS](tab-1) tab** . You should see the Interoperability Portal with an open production containing three `Host` boxes in the center of the screen. If you don't see this, or if it has only partially loaded, click the refresh button in the top right of the window (circled):

![Interop Portal](..\assets\ProductionPortal.png)


We have three business hosts; these are reusable and configurable components that each perform a task.
- **Inbound Hosts** manage a connection to an incoming system — for example, a web form being submitted, an email arriving in an inbox, or a new file being placed in a watched directory.
- **Process Hosts** handle logic-based message routing.
- **Outbound Hosts** handle any results or outbound calls to other systems, for example writing to a database, querying an external API, or sending alerts.

These components can be created from a library of pre-built connectors and added to the UI, or the components can be custom-built in ObjectScript or Python.

In this example, our production receives an order request via the `FromWeb` host and sends it to the `ToOrderProcessor`, which handles updating the database and organizing the shipment.

Let's add another component to send the customer a confirmation email.`

**Select `Create` to add a new component, and choose `Outbound Host` from the drop-down menu.**

![The Create button in the Interoperability Portal toolbar](..\assets\CreateButton.png)

To configure this, select:
  - Outbound Type = `General`
  - Outbound Class = `HoleFoods.Interop.BO.ToEmail` (Scroll to the bottom of the list)
  - Name = `ToEmail`
  - Select `Enable Now`

**When you are finished, click Create.**

**Afterwards, click the new `ToEmail` Host, then click `Start Host` above this, and `OK` to confirm.**

![The Start Host button in the host configuration panel](..\assets\StartHost.png)

# Trying the Production Again

Let's see if our new component works.

**Return to the [Shop](tab-0) tab and submit another order for some more Gummy Rings.** This time, the thank-you page should say that it has sent you an email. Let's check that this is true.

**Open the [Mail](tab-2) tab.** You will see an email inbox. Hopefully, you should see a new message in the inbox. Open the message to see your order confirmation.


# Summary

Here, you've seen how systems can be connected in a traceable and modular way using InterSystems IRIS interoperability productions.

This example connects a web page, our database and an email server in one basic workflow, but we could easily extend this. After all, we still need to handle payment processing — that could be a separate operation with a call to our payment provider.

Different providers might communicate through different protocols and systems, but with InterSystems IRIS, we could tie them together in an efficient, traceable, and reusable way.

