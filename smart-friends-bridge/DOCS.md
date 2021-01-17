# Smart Friends Bridge

## Description

This add-on creates a link between a [Smart Friends Box](https://smart-friends.com/) and a MQTT broker.

This allows you to control all your Smart Friends devices (Schellenberg, ABUS, Paulmann, Steinel, etc...) via MQTT protocol.

<img src="https://github.com/airthusiast/smart-friends-bridge/raw/master/images/doc01.png" width="900">

This add-on is compatible with the following boxes:

- Smart Friends Box
- Schellenberg SH1-Box

## How to use the Smart Friends Bridge?

Follow these simple steps in order to get it up and running:

### Add the repository
- Open the supervisor:

  <img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc02.png" alt="Open the supervisor" width="200">
- Open the add-on store and go to repositories:

  <img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc03.png" alt="Open add-on store and go to repositories" width="600">
- Add Aithusiast addons repository: https://github.com/airthusiast/hassio-addons

  <img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc04.png" alt="Add airthusiast repository" width="250">
- The Schellenberg add-on should now be visible in the store

### Prepare the MQTT Broker

Before going any further, a MQTT broker must be up and running, as it is required.

Detailled information on how to setup MQTT on Hassio is available [here](https://www.home-assistant.io/docs/mqtt/broker/).

### Configuration and first start

- Install the add-on
- Go to configuration tab and specify the connexion settings:
  ```yaml
  connexion:
    host: 192.168.1.3 #----------> IP of your Schellenberg SH1 Box / Smart Friends Box
    port: 4300 #-----------------> Port of the box, generally 4300/tcp
    username: myuser #-----------> Username
    password: mysecret #---------> Password
  advanced":
    enableDebug: true, #---------> Enable or disable debug mode
    cSymbol: "D19033", #---------> Extra param 1
    cSymbolAddon: "i", #---------> Extra param 2
    shcVersion: "2.19.7", #------> Extra param 3
    shApiVersion: "2.15" #-------> Extra param 4
  mqtt:
    url: "mqtt://broker.url", #--> MQTT URL
    username: "myusername", #----> MQTT Broker username
    password: "mypassword" #-----> MQTT Broker password
  ```

  **Extra API parameters**:
  In order to find these values, simply open the Smart Friends App (or Schellenberg app) and go to the information page as illustrated:

  <img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc00.jpg" alt="Gather extra params from app" width="900">

- Now the Smart Friends Bridge add-on is ready to be started.

  <img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc05.png" alt="Start Smart Friends Bridge add-on" width="400">


### Collect devices ID's

Device ID's **are important**, they will be used to interact with the device itself.

Once connection successfully established to the Box, the console will output a complete list of all the devices found in the box.
The output looks like this:

```bash
Device found:
> deviceID:          11223
> masterDeviceID  :  0
> masterDeviceName:  undefined
> deviceName:        Serverstatus
> deviceDesignation: Serverstatus
Device found:
> deviceID:          9589
> deviceName:        SH1-Box
> deviceDesignation: pushNotification
Device found:
> deviceID:          3079 #-------------> Example: Device ID of a roller shutter
> masterDeviceID  :  5243
> masterDeviceName:  Roller Shutter 1
> deviceName:        Motor
> deviceDesignation: Rohrmotor PREMIUM
Device found:
> deviceID:          36221 #-------------> Example: Device ID of a second roller shutter
> masterDeviceID  :  2411
> masterDeviceName:  Roller Shutter 2
> deviceName:        Motor
> deviceDesignation: Rohrmotor PREMIUM
...
...
...
```
Write them down, you will need them in the next step!

**Note:** If debug mode is enabled you will see much more output. If it's too verbose, simply disable it.

#### Information about devices IDs
A physical device can have multiple devices within Smart Friends. They are all grouped by MasterDeviceID:

<img src="https://github.com/airthusiast/smart-friends-bridge/raw/master/images/doc02.png" alt="Schema about device ID" width="600">

Each device has its own purpose, for instance positioning of roller shutter, brightness of light, on/off, etc...

### Using the Brigde

The module can be used to control any type of devices. 
All is needed:
- the correct device ID
- using the correct value format. By observing current values, it is easy to spot the required format.

#### How to get current device value?

Any device value is published in real-time to the following topic:

```bash
schellenberg/device/value/xxxxxx # <---- the device ID
```

Simply replace the xxxxxx by the device ID. 

There is one topic per device. The MQTT client (Hassio, or any other) simply needs to subscribe to the required topic. 

#### How to update device state/value?

Updating a device status is as simple as the previous step.

Each device has a dedicated topic for updates:

```bash
schellenberg/device/value/update/xxxxxx # <---- the device ID to update
```

The MQTT client needs to publish the new value to the dedicated topic. The information will be passed to the Smart Friends Box.

> **Important note:** The module is open and does not validate any given value. Incorrect values will be rejected by the Smart Friends Box. If that's the case, check the logs and fix accordingly.

## Use cases

#### Example #1: Home Assistant covers

This is a simple use case: Controlling roller shutters (alias covers or rolling shutters...)

<img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc01.png" alt="Schellenberg roller shutter example" width="400">

The example shown above simply requires the creation of a **MQTT cover**.

Add the following to your Hassio configuration:

```yaml
cover:
  - platform: mqtt
    name: bedroom_roller_shutter
    device_class: shutter
    retain: false
    qos: 0
    # Payloads
    payload_open:       "1"
    payload_close:      "2"
    payload_stop:       "0"
    # State
    command_topic:      "schellenberg/device/value/update/4224"
    # Position
    position_topic:     "schellenberg/device/value/12522"
    set_position_topic: "schellenberg/device/value/update/12522"
    position_open:      0
    position_closed:    100
  - platform: mqtt
    name: kitchen_roller_shutter
    device_class: shutter
    retain: false
    qos: 0
    # Payloads
    payload_open:       "1"
    payload_close:      "2"
    payload_stop:       "0"
    # State
    command_topic:      "schellenberg/device/value/update/9564"
    # Position
    position_topic:     "schellenberg/device/value/1944"
    set_position_topic: "schellenberg/device/value/update/1944"
    position_open:      0
    position_closed:    100
```

#### Example #2: Philips Hue lamps

The Smart Friends Box is capable of handling any Zigbee device, including Philips Hue lamps.

<img src="https://github.com/airthusiast/hassio-addons/raw/master/smart-friends-bridge/images/doc00.png" alt="Philips Hue example" width="300">

The example shown above simply requires the creation of a **[MQTT light](https://www.home-assistant.io/integrations/light.mqtt/)**.

The MQTT light allows you to interact with a Philipe Hue bulb connected to the Smart Friends Box:

```yaml
light:
  - platform: mqtt
    name: hue_lamp_example
    retain: true
    qos: 0
    # Payloads
    payload_on: "1"
    payload_off: "0"
    # State
    state_topic: "schellenberg/device/value/1236"
    command_topic: "schellenberg/device/value/update/1236"
    # Brightness
    brightness_state_topic: "schellenberg/device/value/7555"
    brightness_command_topic: "schellenberg/device/value/update/7555"
    brightness_scale: 100
    # Color temperature (CCT)
    color_temp_state_topic: "schellenberg/device/value/16666"
    color_temp_command_topic: "schellenberg/device/value/update/16666"
    # Mireds as Kelvin
    min_mireds: 2700
    max_mireds: 6500
```

> Notice: each lamp property is controlled via a dedicated device. All those devices are linked to the same master device ID.