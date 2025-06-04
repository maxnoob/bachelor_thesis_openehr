# 24h Blood Pressure Monitoring – openEHR Prototype (Bachelor Thesis)

This repository contains selected deliverables from the bachelor thesis  
*“Entwicklung eines interoperablen openEHR-Prototypen zur Modernisierung klinischer Anwendungssysteme - Implementiert für die 24-Stunden-Blutdruckmessung am Universitätsspital Basel”* at the Berne University of Applied Sciences.   

The focus is on modeling and prototyping a 24-hour ambulatory blood pressure monitoring (ABPM) workflow using openEHR-based technologies and tools.  

The prototype was developed in collaboration with the University Hospital Basel (USB) and is based on real clinical workflows.

---

## 📁 Repository Contents

`BA_openEHR_Poster.pdf`: Poster presented at the Techday in June 2025 in Biel/Bienne. Provides a visual summary of the methodology and outcomes. Note: The poster content is in German.  
`index.html`: Landing page (used for GitHub Pages) used for the QR code on the poster.    
`/bootcamp-exercises`: Contains two demo applications created during the Medblocks Bootcamp.  
`/prototype`: Contains the main prototype implementation as exported from Better Studio.  
`/template-exports`: Contains the exported templates from the Archetype Designer along with the needed archetypes.  
`/archetypes-ckm-bulk-export`: Contains a bulk export of archetypes from the Clinical Knowledge Manager (CKM) that were used in the prototype.  


---

## About the Project

The prototype was developed to evaluate openEHR's capabilities for structured health data management for the use case of ABPM as part of the planned introduction of a hospital wide openEHR-based data platform. It is based on real clinical workflows at the University Hospital Basel (USB) and focused on:

- Modeling clinical content as templates with archetypes
- Implementing a data entry form using Better Studio (Form Builder & AQL Builder)
- Exploring openEHR-based data querying and visualization
- Comparing to legacy functionality from the in-house CardioApp

---

## 📄 Key Files


### `/prototype/...`
Includes:

- `*.adl`: Archetypes used to model the prototype.
- `*.opt` and `.t.json`: Template exports for data structure definition.
- `*.json` and `.zip`: Exports from the Form Builder and AQL Builder, including visual form configurations and views.

These resources were created using the application Better Studio.

### `/bootcamp-exercises/...`
Demo code created during the openEHR bootcamp by Medblocks, which helped build technical understanding of:
- openEHR REST APIs / EHRbase
- Archetype and template usage
- Composition management
- Data querying with AQL

This code is not used in the final prototype but is provided for learning purposes.

📄 [Instructions and setup guide for the exercise applications](./bootcamp-exercises/README.md)


---

## Limitations

- As of the end of this project, the prototype is not usable as a standalone application, but requires the proprietary software Better Studio as environment to run.

---

## License

This repository is shared under the **MIT License** for educational and non-commercial use. See [LICENSE](./LICENSE) for details.  
Please give credit if reusing the templates, code, or poster content.

---

## 👤 Author & Contact

**Fabian Max Bürki**  
📧 [fabian.buerki@proton.me](mailto:fabian.buerki@proton.me)

---

## 🔗 Related Links

- [openEHR International](https://openehr.org)
- [openEHR Switzerland](https://openehr.ch)
- [Clinical Knowledge Manager (CKM)](https://ckm.openehr.org)
- [Archetype Designer](https://tools.openehr.org/designer/)
- [Medblocks](https://medblocks.com)

